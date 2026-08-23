// lib/pages/shopping_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../providers/meal_plan_provider.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final Set<int> _selectedIds = {};

  bool _allSelected(MealPlanProvider provider) {
    final items = provider.shoppingItems;
    return items.isNotEmpty && _selectedIds.length == items.length;
  }

  void _toggleSelectAll(MealPlanProvider provider) {
    final items = provider.shoppingItems;
    setState(() {
      if (_allSelected(provider)) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(items.where((i) => i.id != null).map((i) => i.id!));
      }
    });
  }

  Future<void> _confirmPurchase() async {
    final provider = context.read<MealPlanProvider>();
    final db = LocalDB();

    final selected = <({int itemId, String name, double amount, String unit})>[];
    for (final item in provider.shoppingItems) {
      if (_selectedIds.contains(item.id)) {
        selected.add((itemId: item.id!, name: item.name, amount: item.amount, unit: item.unit));
      }
    }
    if (selected.isEmpty) return;

    try {
      // 单事务：采购项移入冰箱（同名累加）并删除采购条目
      await db.batchMarkPurchased(selected);

      _selectedIds.clear();
      await provider.loadActivePlan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已确认购买，食材已加入冰箱')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealPlanProvider>();
    final items = provider.shoppingItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('食材采购清单'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: () => _toggleSelectAll(provider),
              icon: Icon(_allSelected(provider) ? Icons.deselect : Icons.select_all, size: 20),
              label: Text(_allSelected(provider) ? '取消全选' : '全选'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  '食材采购清单',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedIds.length} 项已选',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('采购清单为空', style: TextStyle(color: Colors.grey)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: items.map((item) {
                      final isSelected = _selectedIds.contains(item.id);
                      return CheckboxListTile(
                        title: Text(item.name),
                        subtitle: Text(item.displayQuantity),
                        value: isSelected,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedIds.add(item.id!);
                            } else {
                              _selectedIds.remove(item.id!);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedIds.isEmpty ? null : _confirmPurchase,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('确认已购买'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Container(
            height: 120,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/shopping.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}