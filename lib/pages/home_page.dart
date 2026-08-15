// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/user_provider.dart';
import '../models/recipe.dart';
import '../widgets/ai_generating_overlay.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealPlanProvider>().loadActivePlan();
    });
  }

  void _showGenerateDialog() {
    int dishesCount = 3;
    int meatDishes = 1;
    int veggieDishes = 2;
    bool wantSoup = true;
    int cookingTime = 30;
    String cuisineStyle = '中餐';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('菜谱要求'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: dishesCount, decoration: const InputDecoration(labelText: '几道菜'),
                  items: [1,2,3,4,5].map((i) => DropdownMenuItem(value: i, child: Text('$i 道'))).toList(),
                  onChanged: (v) => setDialogState(() => dishesCount = v!),
                ),
                Row(children: [
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: '荤菜'), keyboardType: TextInputType.number, onChanged: (v) => meatDishes = int.tryParse(v) ?? 1)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: '素菜'), keyboardType: TextInputType.number, onChanged: (v) => veggieDishes = int.tryParse(v) ?? 2)),
                ]),
                SwitchListTile(title: const Text('加汤'), value: wantSoup, onChanged: (v) => setDialogState(() => wantSoup = v)),
                TextField(decoration: const InputDecoration(labelText: '烹饪时间限制（分钟）'), keyboardType: TextInputType.number, onChanged: (v) => cookingTime = int.tryParse(v) ?? 30),
                DropdownButtonFormField<String>(
                  value: cuisineStyle, decoration: const InputDecoration(labelText: '菜品风格'),
                  items: ['中餐', '西餐', '日式'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setDialogState(() => cuisineStyle = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(onPressed: () {
              Navigator.pop(ctx);
              context.read<MealPlanProvider>().generateWeekPlan(
                dishesCount: dishesCount, meatDishes: meatDishes, veggieDishes: veggieDishes,
                wantSoup: wantSoup, cookingTimeMinutes: cookingTime, cuisineStyle: cuisineStyle,
              );
            }, child: const Text('生成菜谱')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = context.watch<MealPlanProvider>();
    final userProvider = context.watch<UserProvider>();

    // 如果在生成中，显示生成界面
    if (mealPlanProvider.status == GenerationStatus.generating) {
      return AIGeneratingOverlay(
        imageAsset: 'assets/images/ai_generating_1080x1920.png',
        failedImageAsset: 'assets/images/ai_failed_1080x1920.png',
      );
    }

    // 如果生成失败，显示失败界面
    if (mealPlanProvider.status == GenerationStatus.failed) {
      return AIGeneratingOverlay(
        imageAsset: 'assets/images/ai_generating_1080x1920.png',
        failedImageAsset: 'assets/images/ai_failed_1080x1920.png',
        isFailed: true,
        errorMessage: mealPlanProvider.errorMessage,
        onRetry: () => mealPlanProvider.generateWeekPlan(),
      );
    }

    // 没有活跃计划，显示引导
    if (mealPlanProvider.activePlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('DeepFry'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                const Text('还没有菜谱计划', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                const Text('告诉我你的身体数据和饮食偏好，\n我来为你定制一周健康菜谱。', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: userProvider.hasCompletedOnboarding ? _showGenerateDialog : () => Navigator.pushNamed(context, '/onboarding'),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(userProvider.hasCompletedOnboarding ? '生成一周菜谱' : '开始设置'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 有活跃计划，显示菜谱
    final recipes = mealPlanProvider.currentRecipes;
    final shoppingItems = mealPlanProvider.shoppingItems;
    final unpurchasedCount = shoppingItems.where((i) => !i.purchased).length;
    final weekStart = DateTime.fromMillisecondsSinceEpoch(mealPlanProvider.activePlan!.weekStart);
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepFry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _showGenerateDialog),
        ],
      ),
      body: Column(
        children: [
          // 周选择器
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemBuilder: (_, i) {
                final isSelected = _selectedDay == i;
                final dayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayNames[i], style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                        Text('${weekDays[i].day}', style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 采购清单入口
          if (unpurchasedCount > 0)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.orange),
                title: Text('采购清单（$unpurchasedCount 项待购）'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showShoppingList(context, shoppingItems, mealPlanProvider),
              ),
            ),

          // 当日菜谱
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('今日菜谱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...mealPlanProvider.getRecipesForDay(_selectedDay).map((recipe) => _buildRecipeCard(context, recipe, mealPlanProvider)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, MealPlanProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(recipe.mealType == '早餐' ? Icons.wb_sunny : Icons.restaurant, color: recipe.mealType == '早餐' ? Colors.orange : Colors.blue),
        title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.mealType),
            if (recipe.description.isNotEmpty) Text(recipe.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(recipe.isFavorite ? Icons.favorite : Icons.favorite_border, color: recipe.isFavorite ? Colors.red : null),
          onPressed: () => provider.toggleFavorite(recipe.id!, !recipe.isFavorite),
        ),
        isThreeLine: recipe.description.isNotEmpty,
      ),
    );
  }

  void _showShoppingList(BuildContext context, List<dynamic> items, MealPlanProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            const Text('采购清单', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map((item) => CheckboxListTile(
              title: Text(item.name),
              subtitle: Text(item.quantity),
              value: item.purchased,
              onChanged: (v) {
                if (v == true) {
                  provider.markPurchased(item.id!, item.name, item.quantity);
                  Navigator.pop(ctx);
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}