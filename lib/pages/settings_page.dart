import 'package:flutter/material.dart';

/// 设置页面 — 切换主题、查看关于信息
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // —— 主题切换 ——
          Card(
            child: SwitchListTile(
              title: const Text('深色模式'),
              subtitle: const Text('切换暗色 / 亮色主题'),
              secondary: const Icon(Icons.dark_mode),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) {
                // 切换方式：通过 MaterialApp 的 themeMode
                // 实际项目中可以用 Provider / SharedPreferences 持久化
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('主题切换功能已预留，可接入持久化存储')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // —— 关于 ——
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于 DeepFry'),
              subtitle: Text(
                '版本 1.0.0\n'
                'Flutter ${Theme.of(context).platform == TargetPlatform.iOS ? "iOS" : "Android"} 双端模板',
              ),
            ),
          ),
        ],
      ),
    );
  }
}