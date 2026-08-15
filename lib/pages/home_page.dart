import 'package:flutter/material.dart';
import 'settings_page.dart';

/// 首页 — 展示功能卡片列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepFry'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // —— 卡片 1：计数器（演示交互） ——
          Card(
            child: ListTile(
              leading: const Icon(Icons.exposure),
              title: const Text('计数器'),
              subtitle: Text('你按了 $_counter 次'),
              trailing: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('+1'),
                onPressed: () {
                  setState(() => _counter++);
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // —— 卡片 2：占位功能 ——
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('图片处理'),
              subtitle: const Text('这里可以放你的功能'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),

          const SizedBox(height: 12),

          // —— 卡片 3：占位功能 ——
          Card(
            child: ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享'),
              subtitle: const Text('分享到社交平台'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}