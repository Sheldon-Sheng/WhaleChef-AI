// lib/pages/kitchen_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kitchen_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../models/kitchen_item.dart';
import '../widgets/confirm_dialog.dart';
import '../theme.dart';

/// 默认常用调味料（中餐 + 西餐 + 日式）
const _defaultSeasonings = [
  // 中餐
  '盐', '白糖', '酱油', '老抽', '生抽', '醋', '料酒', '蚝油',
  '豆瓣酱', '甜面酱', '辣椒酱', '芝麻油', '花椒油', '鸡精', '味精',
  '五香粉', '十三香', '白胡椒粉', '黑胡椒粉', '八角', '桂皮', '香叶',
  '干辣椒', '花椒', '淀粉', '老姜', '大蒜', '葱',
  // 西餐
  '橄榄油', '黄油', '黑胡椒碎', '迷迭香', '百里香', '罗勒', '欧芹',
  '牛至', '肉桂粉', '肉豆蔻', '披萨草', '香草精', '柠檬汁',
  // 日式
  '味噌', '味醂', '清酒', '日式酱油', '寿司醋', '芝麻酱',
  '柴鱼片', '昆布', '七味粉', '芥末', '照烧酱', '天妇罗粉',
];

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  bool _hasShownSeasoningDialog = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndCheckSeasonings();
    });
  }

  Future<void> _loadAndCheckSeasonings() async {
    final provider = context.read<KitchenProvider>();
    await provider.loadItems();
    // 首次进入调味料标签且没有调味料时，弹出初始化窗口
    if (!_hasShownSeasoningDialog && provider.seasonings.isEmpty && mounted) {
      _hasShownSeasoningDialog = true;
      _showInitSeasoningsDialog();
    }
  }

  void _showInitSeasoningsDialog() {
    // 初始默认选中所有调味料
    final selected = <String>{..._defaultSeasonings};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('初始化调味料'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('已为您准备了常用调味料列表，请取消勾选您不需要的调味料：', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: _defaultSeasonings.map((name) {
                      final isChecked = selected.contains(name);
                      return CheckboxListTile(
                        dense: true,
                        title: Text(name, style: const TextStyle(fontSize: 14)),
                        value: isChecked,
                        onChanged: (v) {
                          setDialogState(() {
                            if (v == true) {
                              selected.add(name);
                            } else {
                              selected.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('跳过'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _saveInitSeasonings(selected.toList());
              },
              child: Text('确认添加（${selected.length} 项）'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInitSeasonings(List<String> names) async {
    final provider = context.read<KitchenProvider>();
    for (final name in names) {
      await provider.addItem(KitchenItem(type: KitchenItemType.seasoning, name: name));
    }
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
          leading: Icon(type == KitchenItemType.tool ? Icons.kitchen : Icons.science, color: item.isAvailable ? kSeedBlue : Colors.grey),
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
                      final shouldRegenerate = await showConfirmDialog(context,
                        title: '调味料用完',
                        message: '${item.name}已标记为"无"，并已加入采购清单。\n是否需要根据缺少调味料的情况重新规划本周剩余菜谱？',
                        confirmText: '重新规划',
                        cancelText: '稍后再说',
                      );
                      await provider.setSeasoningUnavailable(item.id!);
                      if (shouldRegenerate == true) {
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