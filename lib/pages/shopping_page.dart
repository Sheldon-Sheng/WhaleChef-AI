// lib/pages/shopping_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../providers/meal_plan_provider.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final provider = context.read<MealPlanProvider>();
    final db = LocalDB();

    final selected =
        <({int itemId, String name, double amount, String unit})>[];
    for (final item in provider.shoppingItems) {
      if (_selectedIds.contains(item.id)) {
        selected.add((
          itemId: item.id!,
          name: item.name,
          amount: item.amount,
          unit: item.unit,
        ));
      }
    }
    if (selected.isEmpty) return;

    try {
      // 单事务：采购项移入冰箱（同名累加）并删除采购条目
      await db.batchMarkPurchased(selected);

      _selectedIds.clear();
      await provider.loadActivePlan();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.purchaseSuccess)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.purchaseFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<MealPlanProvider>();
    final items = provider.shoppingItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingListName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: () => _toggleSelectAll(provider),
              icon: Icon(
                _allSelected(provider) ? Icons.deselect : Icons.select_all,
                size: 20,
              ),
              label: Text(
                _allSelected(provider) ? l10n.deselectAll : l10n.selectAll,
              ),
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
                  l10n.shoppingListName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.selectedCount(_selectedIds.length),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      l10n.shoppingEmpty,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
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
                label: Text(l10n.confirmPurchased),
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
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/shopping.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
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
