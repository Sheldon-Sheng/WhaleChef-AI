// lib/pages/fridge_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fridge_provider.dart';
import '../models/ingredient.dart';
import '../l10n/app_localizations.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _editingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FridgeProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _nameController.clear();
    _qtyController.clear();
    _categoryController.clear();
    _editingId = null;
    _showDialog();
  }

  void _showEditDialog(Ingredient item) {
    _nameController.text = item.name;
    _qtyController.text = item.quantity; // 兼容显示 "5个"
    _categoryController.text = item.category ?? '';
    _editingId = item.id.toString();
    _showDialog();
  }

  void _showDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _editingId == null ? l10n.fridgeAddTitle : l10n.fridgeEditTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.fridgeName),
            ),
            TextField(
              controller: _qtyController,
              decoration: InputDecoration(labelText: l10n.fridgeQty),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: l10n.fridgeCategory),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty || _qtyController.text.isEmpty) {
                return;
              }
              final qtyMatch = RegExp(r'^([\d.]+)\s*(.*)$')
                  .firstMatch(_qtyController.text.trim());
              final amount = qtyMatch != null
                  ? (double.tryParse(qtyMatch.group(1)!) ?? 0)
                  : 0.0;
              final unit = qtyMatch != null
                  ? (qtyMatch.group(2)?.trim() ?? '')
                  : _qtyController.text.trim();
              if (_editingId != null) {
                await context.read<FridgeProvider>().updateItem(
                  Ingredient(
                    id: int.parse(_editingId!),
                    name: _nameController.text,
                    amount: amount,
                    unit: unit,
                    category: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
                  ),
                );
              } else {
                await context.read<FridgeProvider>().addItem(
                  Ingredient(
                    name: _nameController.text,
                    amount: amount,
                    unit: unit,
                    category: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
                  ),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FridgeProvider>();
    final items = provider.items;

    // 按分类分组
    final grouped = <String, List<Ingredient>>{};
    for (final item in items) {
      final cat = item.category ?? l10n.fridgeUncategorized;
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabFridge),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: items.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.fridgeClearTitle),
                        content: Text(l10n.fridgeClearBody),
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
                    if (ok == true) {
                      await context.read<FridgeProvider>().clearAll();
                    }
                  },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(child: Text(l10n.fridgeEmpty))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries
                  .map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map(
                          (item) => Card(
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text(item.quantity),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(l10n.deleteConfirmTitle),
                                          content: Text(
                                            l10n.deleteConfirmBody(item.name),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text(l10n.cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: Text(l10n.delete),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context
                                            .read<FridgeProvider>()
                                            .deleteItem(item.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
