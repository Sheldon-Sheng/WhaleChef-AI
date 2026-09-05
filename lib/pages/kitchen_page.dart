// lib/pages/kitchen_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kitchen_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../models/kitchen_item.dart';
import '../widgets/confirm_dialog.dart';
import '../theme.dart';
import '../utils/default_seasonings.dart';
import '../utils/default_kitchen_tools.dart';
import '../l10n/app_localizations.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  bool _hasShownSeasoningDialog = false;
  bool _hasShownToolsDialog = false;
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = Localizations.localeOf(context);
    // 语言切换后重置「已弹出初始化对话框」标记，让新的英文默认调味料重新初始化
    if (_lastLocale != null && _lastLocale != loc) {
      _hasShownSeasoningDialog = false;
      _hasShownToolsDialog = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndCheck());
    }
    _lastLocale = loc;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndCheck();
    });
  }

  Future<void> _loadAndCheck() async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<KitchenProvider>();
    await provider.loadItems();
    if (!mounted) return;
    // 首次进入「厨具」标签且没有厨具时，弹出初始化窗口
    if (!_hasShownToolsDialog && provider.tools.isEmpty) {
      _hasShownToolsDialog = true;
      await _showInitItemsDialog(
        title: l10n.toolInitTitle,
        prompt: l10n.toolInitPrompt,
        defaults: defaultKitchenTools,
        type: KitchenItemType.tool,
      );
    }
    // 首次进入「调味料」标签且没有调味料时，弹出初始化窗口
    if (!_hasShownSeasoningDialog && provider.seasonings.isEmpty) {
      _hasShownSeasoningDialog = true;
      await _showInitItemsDialog(
        title: l10n.seasoningInitTitle,
        prompt: l10n.seasoningInitPrompt,
        defaults: defaultSeasonings,
        type: KitchenItemType.seasoning,
      );
    }
  }

  Future<void> _showInitItemsDialog({
    required String title,
    required String prompt,
    required List<String> defaults,
    required KitchenItemType type,
  }) async {
    final l10n = AppLocalizations.of(context);
    // 初始默认选中全部
    final selected = <String>{...defaults};
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prompt, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: defaults.map((name) {
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
              child: Text(l10n.seasoningSkip),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _saveInitItems(selected.toList(), type);
              },
              child: Text(l10n.seasoningConfirmAdd(selected.length)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInitItems(List<String> names, KitchenItemType type) async {
    final provider = context.read<KitchenProvider>();
    for (final name in names) {
      await provider.addItem(KitchenItem(type: type, name: name));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showAddDialog(KitchenItemType type) {
    final l10n = AppLocalizations.of(context);
    _nameController.clear();
    final typeLabel = type == KitchenItemType.tool
        ? l10n.kitchenTypeTool
        : l10n.kitchenTypeSeasoning;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.kitchenAddDialogTitle(typeLabel)),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: l10n.kitchenName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                await context.read<KitchenProvider>().addItem(
                  KitchenItem(type: type, name: _nameController.text),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<KitchenProvider>();
    final tools = provider.tools;
    final seasonings = provider.seasonings;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabKitchen),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.kitchenTabTools),
            Tab(text: l10n.kitchenTabSeasonings),
          ],
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
        onPressed: () => _showAddDialog(
          _tabController.index == 0
              ? KitchenItemType.tool
              : KitchenItemType.seasoning,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    KitchenProvider provider,
    List<KitchenItem> items,
    KitchenItemType type,
  ) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = type == KitchenItemType.tool
        ? l10n.kitchenTypeTool
        : l10n.kitchenTypeSeasoning;
    if (items.isEmpty) {
      return Center(child: Text(l10n.kitchenEmpty(typeLabel)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map(
            (item) => Card(
              child: ListTile(
                leading: Icon(
                  type == KitchenItemType.tool ? Icons.kitchen : Icons.science,
                  color: item.isAvailable ? kSeedBlue : Colors.grey,
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    color: item.isAvailable ? null : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  item.isAvailable
                      ? l10n.kitchenAvailable
                      : l10n.kitchenUnavailable,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == KitchenItemType.seasoning)
                      IconButton(
                        icon: Icon(
                          item.isAvailable
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: item.isAvailable ? Colors.green : Colors.grey,
                        ),
                        onPressed: () async {
                          if (item.isAvailable) {
                            final shouldRegenerate = await showConfirmDialog(
                              context,
                              title: l10n.seasoningOutTitle,
                              message: l10n.seasoningOutBody(item.name),
                              confirmText: l10n.replan,
                              cancelText: l10n.later,
                            );
                            await provider.setSeasoningUnavailable(item.id!);
                            if (shouldRegenerate == true) {
                              if (context.mounted) {
                                final currentDay = DateTime.now().weekday - 1;
                                context
                                    .read<MealPlanProvider>()
                                    .regenerateRemainingDays(currentDay);
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              }
                            }
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: l10n.deleteConfirmTitle,
                          message: l10n.deleteConfirmBody(item.name),
                          confirmText: l10n.delete,
                        );
                        if (confirm == true) {
                          provider.deleteItem(item.id!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
