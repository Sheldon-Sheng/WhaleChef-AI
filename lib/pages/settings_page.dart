// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/kitchen_provider.dart';
import '../data/local_db.dart';
import '../theme.dart';

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

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _db.getAIConfig();
    _apiKeyController.text = config['api_key'] ?? '';
    _modelController.text = config['model'] ?? 'deepseek-v4-flash';
    _baseUrlController.text = config['base_url'] ?? '';
    setState(() {});
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('AI 配置已保存')));
  }

  Future<void> _deleteHistory() async {
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
          title: const Text('确认清除'),
          content: Text('确定清除 $date 之前的所有菜谱记录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('清除'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await context.read<MealPlanProvider>().deleteHistoryBefore(date);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('历史菜谱已清除')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
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
                    title: const Text('个人信息'),
                    subtitle: Text(
                      user != null
                          ? '${user.age}岁 · ${user.gender} · ${user.height}cm'
                          : '未设置',
                    ),
                    initiallyExpanded: user == null,
                    children: [
                      if (user != null) ...[
                        ListTile(
                          title: Text('年龄: ${user.age}'),
                          subtitle: Text(
                            '身高: ${user.height}cm 体重: ${user.weight}kg',
                          ),
                        ),
                        ListTile(
                          title: Text('目标体重: ${user.targetWeight}kg'),
                          subtitle: Text('目标体脂率: ${user.targetBodyFat}%'),
                        ),
                        ListTile(
                          title: Text('爱吃: ${user.preferredFoods}'),
                          subtitle: Text('讨厌: ${user.dislikedFoods}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/onboarding',
                            ),
                            child: const Text('修改个人信息'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // AI 配置
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.smart_toy),
                    title: const Text('AI 配置'),
                    subtitle: const Text('API 设置'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _apiKeyController,
                              decoration: InputDecoration(
                                labelText: 'API Key',
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
                              decoration: const InputDecoration(
                                labelText: '模型名称',
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'AI 服务商 (Base URL)',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: '获取 API Key 教程',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('获取 API Key 教程（待补充）'),
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
                                      child: Text(e.key),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: _customUrlKey,
                                    child: Text('自定义 URL…'),
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
                                  decoration: const InputDecoration(
                                    labelText: '自定义 Base URL',
                                    helperText: '自动补 /chat/completions',
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
                                child: const Text('保存配置'),
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
                    title: const Text('历史菜谱管理'),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_sweep),
                        title: const Text('清除指定时间前的菜谱'),
                        subtitle: const Text('可选择日期，清除该日期之前的所有记录'),
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
                    title: const Text('我的收藏'),
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
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Text('还没有收藏的菜谱'),
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
