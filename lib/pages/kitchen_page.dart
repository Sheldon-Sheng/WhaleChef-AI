// lib/pages/kitchen_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kitchen_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../models/kitchen_item.dart';
import '../widgets/confirm_dialog.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showAddDialog(KitchenItemType type) {
    _nameController.clear();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('添加${type == KitchenItemType.tool ? '厨具' : '调味料'}'),
      content: TextField(controller: _nameController, decoration: const InputDecoration(labelText: '名称')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(onPressed: () async {
          if (_nameController.text.isNotEmpty) {
            await context.read<KitchenProvider>().addItem(KitchenItem(type: type, name: _nameController.text));
            if (ctx.mounted) Navigator.pop(ctx);
          }
        }, child: const Text('添加')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KitchenProvider>();
    final tools = provider.tools;
    final seasonings = provider.seasonings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('厨房'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '厨具'), Tab(text: '调味料')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(context, provider, tools, KitchenItemType.tool),
          _buildList(context, provider, seasonings, KitchenItemType.seasoning),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(_tabController.index == 0 ? KitchenItemType.tool : KitchenItemType.seasoning),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, KitchenProvider provider, List<KitchenItem> items, KitchenItemType type) {
    if (items.isEmpty) {
      return Center(child: Text('还没有${type == KitchenItemType.tool ? '厨具' : '调味料'}，点击右下角 + 添加'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items.map((item) => Card(
        child: ListTile(
          leading: Icon(type == KitchenItemType.tool ? Icons.kitchen : Icons.science, color: item.isAvailable ? Colors.orange : Colors.grey),
          title: Text(item.name, style: TextStyle(color: item.isAvailable ? null : Colors.grey)),
          subtitle: Text(item.isAvailable ? '有' : '无'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == KitchenItemType.seasoning)
                IconButton(
                  icon: Icon(item.isAvailable ? Icons.check_circle : Icons.radio_button_unchecked, color: item.isAvailable ? Colors.green : Colors.grey),
                  onPressed: () async {
                    if (item.isAvailable) {
                      // 标记为无
                      final shouldRegenerate = await showConfirmDialog(context,
                        title: '调味料用完',
                        message: '${item.name}已标记为"无"，并已加入采购清单。\n是否需要根据缺少调味料的情况重新规划本周剩余菜谱？',
                        confirmText: '重新规划',
                        cancelText: '稍后再说',
                      );
                      await provider.setSeasoningUnavailable(item.id!);
                      if (shouldRegenerate == true) {
                        // 触发重排
                        if (context.mounted) {
                          final currentDay = DateTime.now().weekday - 1;
                          context.read<MealPlanProvider>().regenerateRemainingDays(currentDay);
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    }
                  },
                ),
              IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () async {
                final confirm = await showConfirmDialog(context, title: '确认删除', message: '确定删除「${item.name}」吗？', confirmText: '删除');
                if (confirm == true) {
                  provider.deleteItem(item.id!);
                }
              }),
            ],
          ),
        ),
      )).toList(),
    );
  }
}