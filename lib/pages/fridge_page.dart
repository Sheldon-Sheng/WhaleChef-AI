// lib/pages/fridge_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fridge_provider.dart';
import '../models/ingredient.dart';

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
    _qtyController.text = item.quantity;
    _categoryController.text = item.category ?? '';
    _editingId = item.id.toString();
    _showDialog();
  }

  void _showDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(_editingId == null ? '添加食材' : '编辑食材'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: '食材名')),
          TextField(controller: _qtyController, decoration: const InputDecoration(labelText: '数量（如: 500g、3个）')),
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: '分类（可选）')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(onPressed: () async {
          if (_nameController.text.isEmpty || _qtyController.text.isEmpty) return;
          if (_editingId != null) {
            await context.read<FridgeProvider>().updateItem(Ingredient(
              id: int.parse(_editingId!),
              name: _nameController.text,
              quantity: _qtyController.text,
              category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
            ));
          } else {
            await context.read<FridgeProvider>().addItem(Ingredient(
              name: _nameController.text,
              quantity: _qtyController.text,
              category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
            ));
          }
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('保存')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FridgeProvider>();
    final items = provider.items;

    // 按分类分组
    final grouped = <String, List<Ingredient>>{};
    for (final item in items) {
      final cat = item.category ?? '未分类';
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('冰箱'), backgroundColor: Theme.of(context).colorScheme.inversePrimary, actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
      ]),
      body: provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : items.isEmpty
          ? const Center(child: Text('冰箱是空的，点击右上角 + 添加食材'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...entry.value.map((item) => Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.quantity),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditDialog(item)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () async {
                            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                              title: const Text('确认删除'),
                              content: Text('确定删除「${item.name}」吗？'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
                              ],
                            ));
                            if (confirm == true && context.mounted) {
                              context.read<FridgeProvider>().deleteItem(item.id!);
                            }
                          }),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
              )).toList(),
            ),
    );
  }
}