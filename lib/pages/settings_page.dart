// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/kitchen_provider.dart';
import '../data/local_db.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _db = LocalDB();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  bool _apiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _db.getAIConfig();
    _apiKeyController.text = config['api_key'] ?? '';
    _modelController.text = config['model'] ?? 'deepseek-v4-flash';
    setState(() {});
  }

  Future<void> _saveConfig() async {
    await _db.saveAIConfig(_apiKeyController.text, _modelController.text);
    // 刷新各 Provider 持有的 MealPlannerService 的 API 配置
    if (!mounted) return;
    final mealPlanProvider = context.read<MealPlanProvider>();
    final kitchenProvider = context.read<KitchenProvider>();
    await mealPlanProvider.refreshAPIConfig();
    await kitchenProvider.refreshAPIConfig();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 配置已保存')));
  }

  Future<void> _deleteHistory() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
    );
    if (date != null) {
      final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: Text('确定清除 $date 之前的所有菜谱记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清除')),
        ],
      ));
      if (confirm == true) {
        await context.read<MealPlanProvider>().deleteHistoryBefore(date);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('历史菜谱已清除')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 个人信息
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.person),
              title: const Text('个人信息'),
              subtitle: Text(user != null ? '${user.age}岁 · ${user.gender} · ${user.height}cm' : '未设置'),
              initiallyExpanded: user == null,
              children: [
                if (user != null) ...[
                  ListTile(title: Text('年龄: ${user.age}'), subtitle: Text('身高: ${user.height}cm 体重: ${user.weight}kg')),
                  ListTile(title: Text('目标体重: ${user.targetWeight}kg'), subtitle: Text('目标体脂率: ${user.targetBodyFat}%')),
                  ListTile(title: Text('爱吃: ${user.preferredFoods}'), subtitle: Text('讨厌: ${user.dislikedFoods}')),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding'),
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
              subtitle: const Text('DeepSeek API 设置'),
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
                            icon: Icon(_apiKeyVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _apiKeyVisible = !_apiKeyVisible),
                          ),
                        ),
                        obscureText: !_apiKeyVisible,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _modelController,
                        decoration: const InputDecoration(labelText: '模型名称'),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveConfig, child: const Text('保存配置'))),
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
                showModalBottomSheet(context: context, builder: (ctx) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: favorites.isEmpty
                    ? [const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('还没有收藏的菜谱')))]
                    : favorites.map((r) => ListTile(
                        title: Text(r.name),
                        subtitle: Text('${r.mealType} · ${r.dayIndex + 1}'),
                      )).toList(),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}