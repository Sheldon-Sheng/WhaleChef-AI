// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/kitchen_provider.dart';
import '../providers/fridge_provider.dart';
import '../data/local_db.dart';
import '../models/cooking_record.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_provider.dart';
import '../l10n/app_language.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _db = LocalDB();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _baseUrlController = TextEditingController();
  bool _apiKeyVisible = false;
  List<CookingRecord> _cookingHistory = [];

  /// 常见 OpenAI 兼容 AI 服务的 Base URL 预设
  static const _aiBaseUrlPresets = <String, String>{
    'DeepSeek': 'https://api.deepseek.com/v1',
    'OpenAI': 'https://api.openai.com/v1',
    'Moonshot': 'https://api.moonshot.cn/v1',
    '通义千问': 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    '智谱 GLM': 'https://open.bigmodel.cn/api/paas/v4',
    'SiliconFlow': 'https://api.siliconflow.cn/v1',
  };
  static const _customUrlKey = '__custom__';

  /// 当前 base URL 对应的下拉项 key：匹配预设返回其名，否则返回「自定义」
  String _currentUrlPresetKey() {
    final url = _baseUrlController.text.trim();
    for (final e in _aiBaseUrlPresets.entries) {
      if (e.value == url) return e.key;
    }
    return _customUrlKey;
  }

  /// 预设 key → 当前语言的显示名
  String _presetLabel(String key) => switch (key) {
    'DeepSeek' => AppLocalizations.of(context).presetDeepSeek,
    'OpenAI' => AppLocalizations.of(context).presetOpenAI,
    'Moonshot' => AppLocalizations.of(context).presetMoonshot,
    '通义千问' => AppLocalizations.of(context).presetQwen,
    '智谱 GLM' => AppLocalizations.of(context).presetZhipu,
    'SiliconFlow' => AppLocalizations.of(context).presetSiliconFlow,
    _ => key,
  };

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _loadCookingHistory();
  }

  Future<void> _loadConfig() async {
    final config = await _db.getAIConfig();
    _apiKeyController.text = config['api_key'] ?? '';
    _modelController.text = config['model'] ?? 'deepseek-v4-flash';
    _baseUrlController.text = config['base_url'] ?? '';
    setState(() {});
  }

  /// 加载已记录的烹饪历史(点「已完成今天的烹饪」写入)
  Future<void> _loadCookingHistory() async {
    final records = await _db.getCookingRecords();
    if (!mounted) return;
    setState(() => _cookingHistory = records);
  }

  Future<void> _saveConfig() async {
    await _db.saveAIConfig(
      _apiKeyController.text,
      _modelController.text,
      _baseUrlController.text,
    );
    // 刷新各 Provider 持有的 MealPlannerService 的 API 配置
    if (!mounted) return;
    final mealPlanProvider = context.read<MealPlanProvider>();
    final kitchenProvider = context.read<KitchenProvider>();
    await mealPlanProvider.refreshAPIConfig();
    await kitchenProvider.refreshAPIConfig();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).aiConfigSaved)),
    );
  }

  Future<void> _deleteHistory() async {
    final l10n = AppLocalizations.of(context);
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
    );
    if (date != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.historyClearConfirmTitle),
          content: Text(l10n.historyClearConfirmBody(date.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.clear),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await context.read<MealPlanProvider>().deleteHistoryBefore(date);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
        }
      }
    }
  }

  /// 切换语言：清空用户生成数据(菜谱/采购/冰箱/调味料)，并刷新相关 Provider。
  Future<void> _onLanguageChanged(Locale newLocale) async {
    if (newLocale == LocaleProvider.instance.locale) return;
    await _db.clearUserGeneratedData();
    await Future.wait([
      context.read<FridgeProvider>().loadItems(),
      context.read<KitchenProvider>().loadItems(),
      context.read<MealPlanProvider>().loadActivePlan(),
    ]);
    if (!mounted) return;
    await LocaleProvider.instance.setLocale(newLocale);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).languageChangedToast),
        ),
      );
    }
  }

  String _genderLabel(String g) {
    final l10n = AppLocalizations.of(context);
    if (g == '男') return l10n.genderMale;
    if (g == '女') return l10n.genderFemale;
    return g;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;
    final ageUnit = AppLanguage.isEnglish ? 'yrs' : '岁';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSettings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 个人信息
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.profileTitle),
                    subtitle: Text(
                      user != null
                          ? '${user.age}$ageUnit · ${_genderLabel(user.gender)} · ${user.height}cm'
                          : l10n.profileUnset,
                    ),
                    initiallyExpanded: user == null,
                    children: [
                      if (user != null) ...[
                        ListTile(
                          title: Text(l10n.profileAgeLabel(user.age)),
                          subtitle: Text(
                            l10n.profileHeightLabel(user.height, user.weight),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            l10n.profileTargetWeight(user.targetWeight),
                          ),
                          subtitle: Text(
                            l10n.profileTargetBodyFat(user.targetBodyFat),
                          ),
                        ),
                        ListTile(
                          title: Text(l10n.profileLikes(user.preferredFoods)),
                          subtitle: Text(
                            l10n.profileDislikes(user.dislikedFoods),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/onboarding',
                            ),
                            child: Text(l10n.editProfile),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 语言
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.languageTitle),
                    subtitle: Text(l10n.languageUsageNote),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SegmentedButton<Locale>(
                          segments: [
                            ButtonSegment(
                              value: const Locale('zh'),
                              label: Text(l10n.chinese),
                            ),
                            ButtonSegment(
                              value: const Locale('en'),
                              label: Text(l10n.english),
                            ),
                          ],
                          selected: {LocaleProvider.instance.locale},
                          onSelectionChanged: (s) {
                            final v = s.first;
                            if (v != LocaleProvider.instance.locale) {
                              _onLanguageChanged(v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // AI 配置
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.smart_toy),
                    title: Text(l10n.aiConfigTitle),
                    subtitle: Text(l10n.apiSettings),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _apiKeyController,
                              decoration: InputDecoration(
                                labelText: l10n.apiKey,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _apiKeyVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(
                                    () => _apiKeyVisible = !_apiKeyVisible,
                                  ),
                                ),
                              ),
                              obscureText: !_apiKeyVisible,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _modelController,
                              decoration: InputDecoration(
                                labelText: l10n.modelName,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: l10n.baseUrlLabel,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: l10n.apiKeyTutorial,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.apiKeyTutorialToast),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _currentUrlPresetKey(),
                                isExpanded: true,
                                isDense: true,
                                items: [
                                  ..._aiBaseUrlPresets.entries.map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(_presetLabel(e.key)),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: _customUrlKey,
                                    child: Text(l10n.customUrl),
                                  ),
                                ],
                                onChanged: (v) => setState(() {
                                  if (v == null) return;
                                  if (v == _customUrlKey) {
                                    _baseUrlController.clear();
                                  } else {
                                    _baseUrlController.text =
                                        _aiBaseUrlPresets[v]!;
                                  }
                                }),
                              ),
                            ),
                            if (_currentUrlPresetKey() == _customUrlKey)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: _baseUrlController,
                                  decoration: InputDecoration(
                                    labelText: l10n.customBaseUrl,
                                    helperText: l10n.baseUrlHelper,
                                  ),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveConfig,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kSeedBlue,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(l10n.saveConfig),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 菜谱管理
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.history),
                    title: Text(l10n.historyManagement),
                    children: [
                      const Divider(),
                      // 已记录的烹饪历史(点「已完成今天的烹饪」写入)
                      if (_cookingHistory.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            l10n.historyNoRecords,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ..._cookingHistory.map((r) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                            r.recordDate,
                          );
                          final dateStr = DateFormat('yyyy/M/d').format(d);
                          final sep = AppLanguage.isEnglish ? ', ' : '、';
                          final names = r.recipeItems
                              .map((i) => i.name)
                              .join(sep);
                          return ListTile(
                            dense: true,
                            title: Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${names.isEmpty ? '—' : names} · ${r.totalCalories.toInt()} ${l10n.statsCaloriesUnit}',
                            ),
                          );
                        }),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.delete_sweep),
                        title: Text(l10n.historyClearSummary),
                        subtitle: Text(l10n.historyClearHelper),
                        onTap: _deleteHistory,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 收藏
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text(l10n.favoritesTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final favorites = await userProvider.getFavoriteRecipes();
                      if (!mounted) return;
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => ListView(
                          padding: const EdgeInsets.all(16),
                          children: favorites.isEmpty
                              ? [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Text(l10n.favoritesEmpty),
                                    ),
                                  ),
                                ]
                              : favorites
                                    .map(
                                      (r) => ListTile(
                                        title: Text(r.name),
                                        subtitle: Text(
                                          '${r.mealType} · ${r.dayIndex + 1}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Image.asset(
              'assets/images/ponding.png',
              width: double.infinity,
              height: 187,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
