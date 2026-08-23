// lib/pages/home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/user_provider.dart';
import '../models/recipe.dart';
import '../widgets/ai_generating_overlay.dart';
import 'recipe_detail_page.dart';
import 'shopping_page.dart';
import '../theme.dart';
import '../utils/dish_count.dart';
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
    bool wantSoup = true;
    int cookingTime = 30;
    String cuisineStyle = '中餐';
    bool wantBreakfast = true;
    bool wantLunch = true;
    bool wantDinner = true;
    bool preferFavorites = false;
    int favoriteCount = 0;
    String? favoriteError;

    // 收藏菜谱数量上限 = 一周餐次总量
    final maxRecipes = List.generate(7, (_) => [
      if (wantBreakfast) '早餐',
      if (wantLunch) '午餐',
      if (wantDinner) '晚餐',
    ]).expand((e) => e).length;

    void validateFavoriteCount(String value, StateSetter setDialogState) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed > maxRecipes && maxRecipes > 0) {
        setDialogState(() {
          favoriteError = '数字不能超过 $maxRecipes';
          favoriteCount = parsed;
        });
      } else {
        setDialogState(() {
          favoriteError = null;
          favoriteCount = parsed ?? 0;
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final breakdown = computeDishBreakdown(dishesCount, meatDishes);
          return AlertDialog(
          title: const Text('菜谱要求'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: dishesCount, decoration: const InputDecoration(labelText: '几道菜'),
                  items: [1,2,3,4,5].map((i) => DropdownMenuItem(value: i, child: Text('$i 道'))).toList(),
                  onChanged: (v) => setDialogState(() {
                    dishesCount = v!;
                    meatDishes = meatDishes.clamp(0, dishesCount);
                  }),
                ),
                Row(children: [
                  Expanded(child: InputDecorator(
                    decoration: const InputDecoration(labelText: '荤菜'),
                    child: DropdownButton<int>(
                      value: breakdown.meat,
                      isExpanded: true,
                      isDense: true,
                      items: List.generate(dishesCount + 1, (i) => DropdownMenuItem(value: i, child: Text('$i 道'))),
                      onChanged: (v) => setDialogState(() => meatDishes = v!),
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: InputDecorator(
                    decoration: const InputDecoration(labelText: '素菜'),
                    child: Text('${breakdown.veggie} 道'),
                  )),
                ]),
                SwitchListTile(title: const Text('加汤'), value: wantSoup, onChanged: (v) => setDialogState(() => wantSoup = v)),
                TextField(decoration: const InputDecoration(labelText: '烹饪时间限制（分钟）'), keyboardType: TextInputType.number, onChanged: (v) => cookingTime = int.tryParse(v) ?? 30),
                DropdownButtonFormField<String>(
                  initialValue: cuisineStyle, decoration: const InputDecoration(labelText: '菜品风格'),
                  items: ['中餐', '西餐', '日式'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setDialogState(() => cuisineStyle = v!),
                ),
                const Divider(),
                const Text('请选择需要规划的餐次：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                CheckboxListTile(title: const Text('早餐'), value: wantBreakfast, onChanged: (v) => setDialogState(() => wantBreakfast = v ?? true)),
                CheckboxListTile(title: const Text('午餐'), value: wantLunch, onChanged: (v) => setDialogState(() => wantLunch = v ?? true)),
                CheckboxListTile(title: const Text('晚餐'), value: wantDinner, onChanged: (v) => setDialogState(() => wantDinner = v ?? true)),
                const Divider(),
                CheckboxListTile(
                  title: const Text('优先在收藏菜谱中选择'),
                  value: preferFavorites,
                  onChanged: (v) => setDialogState(() => preferFavorites = v ?? false),
                ),
                if (preferFavorites)
                  TextField(
                    decoration: InputDecoration(
                      labelText: '优先使用收藏菜谱数量',
                      helperText: '最多 $maxRecipes 道（一周共 $maxRecipes 餐）',
                      errorText: favoriteError,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => validateFavoriteCount(v, setDialogState),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(onPressed: () {
              Navigator.pop(ctx);
              context.read<MealPlanProvider>().generateWeekPlan(
                dishesCount: dishesCount, meatDishes: breakdown.meat, veggieDishes: breakdown.veggie,
                wantSoup: wantSoup, cookingTimeMinutes: cookingTime, cuisineStyle: cuisineStyle,
                wantBreakfast: wantBreakfast, wantLunch: wantLunch, wantDinner: wantDinner,
                preferFavorites: preferFavorites, favoriteCount: favoriteCount,
              );
            }, child: const Text('生成菜谱')),
          ],
        );
        },
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
        imageAsset: 'assets/images/loading.png',
      );
    }

    // 如果生成失败，显示失败界面
    if (mealPlanProvider.status == GenerationStatus.failed) {
      return AIGeneratingOverlay(
        imageAsset: 'assets/images/loading.png',
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
    final shoppingItems = mealPlanProvider.shoppingItems;
    final unpurchasedCount = shoppingItems.where((i) => !i.purchased).length;
    final weekStart = DateTime.fromMillisecondsSinceEpoch(mealPlanProvider.activePlan!.weekStart);
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    // 解析计划配置，获取标签
    String planTag = '';
    try {
      final config = mealPlanProvider.activePlan!.planConfig;
      if (config.isNotEmpty && config != '{}') {
        final json = jsonDecode(config) as Map<String, dynamic>;
        final parts = <String>[];
        final style = json['cuisine_style'] as String?;
        if (style != null && style.isNotEmpty) parts.add(style);
        final dishes = json['dishes_count'] as int?;
        if (dishes != null) parts.add('$dishes 道菜');
        if (json['want_soup'] == true) parts.add('加汤');
        final time = json['cooking_time'] as int?;
        if (time != null) parts.add('${time}min');
        if (parts.isNotEmpty) planTag = parts.join(' · ');
      }
    } catch (_) {}

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
                leading: const Icon(Icons.shopping_cart, color: kSeedBlue),
                title: Text('食材采购清单（$unpurchasedCount 项待购）'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingPage())),
              ),
            ),

          // 当日菜谱
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _selectedDay == 0 ? '今日菜谱' : '${['周一','周二','周三','周四','周五','周六','周日'][_selectedDay]}菜谱',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (planTag.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        planTag,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                ...mealPlanProvider.getRecipesForDay(_selectedDay).map((recipe) => _buildRecipeCard(context, recipe, mealPlanProvider)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmTodayCooking(context, mealPlanProvider),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('已完成今天的烹饪'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmTodayCooking(BuildContext context, MealPlanProvider provider) async {
    final recipes = provider.getRecipesForDay(_selectedDay);
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('今日没有菜谱')),
      );
      return;
    }

    // 最终确认
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认完成'),
        content: const Text('确认完成今日烹饪吗？\n\n将从冰箱扣除今日所需食材，不足部分从采购清单中扣除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认完成')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await provider.completeTodayCooking(_selectedDay);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已完成今日烹饪！')),
        );
      }
    }
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, MealPlanProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(recipe.mealType == '早餐' ? Icons.wb_sunny : Icons.restaurant, color: recipe.mealType == '早餐' ? const Color(0xFF90CAF9) : kSeedBlue),
        title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.mealType),
            if (recipe.description.isNotEmpty)
              Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(recipe.isFavorite ? Icons.favorite : Icons.favorite_border, color: recipe.isFavorite ? Colors.red : null, size: 20),
              onPressed: () => provider.toggleFavorite(recipe.id!, !recipe.isFavorite),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe))),
      ),
    );
  }
}