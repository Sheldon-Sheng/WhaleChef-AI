// lib/services/meal_planner.dart
import 'dart:convert';
import '../data/local_db.dart';
import '../models/user_profile.dart';
import '../models/kitchen_item.dart';
import '../models/recipe.dart';
import '../models/weekly_plan.dart';
import '../models/shopping_item.dart';
import 'prompt_builder.dart';
import 'deepseek_api.dart';

class MealPlannerService {
  final LocalDB _db = LocalDB();
  late DeepSeekAPI _api;

  MealPlannerService();

  Future<void> _initAPI() async {
    final config = await _db.getAIConfig();
    _api = DeepSeekAPI(
      apiKey: config['api_key'] ?? '',
      model: config['model'] ?? 'deepseek-v4-flash',
    );
  }

  /// 重新初始化 API（用户修改配置后调用）
  Future<void> refreshAPIConfig() async {
    await _initAPI();
  }

  /// 生成一周菜谱
  Future<Map<String, dynamic>> generateWeekPlan({
    int dishesCount = 3,
    int meatDishes = 1,
    int veggieDishes = 2,
    bool wantSoup = true,
    int cookingTimeMinutes = 30,
    String cuisineStyle = '中餐',
  }) async {
    await _initAPI();

    // 1. 获取所有数据
    final user = await _db.getUserProfile();
    if (user == null) throw Exception('请先完成个人资料设置');

    final fridgeItems = await _db.getIngredients();
    final kitchenItems = await _db.getKitchenItems();
    final tools = kitchenItems.where((i) => i.type == KitchenItemType.tool).toList();
    final seasonings = kitchenItems.where((i) => i.type == KitchenItemType.seasoning).toList();

    // 2. 获取过去 1 个月的历史菜谱
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    final now = DateTime.now().millisecondsSinceEpoch;
    final historyRecipes = await _db.getRecipesInDateRange(oneMonthAgo, now);

    // 3. 组装 Prompt
    final prompt = PromptBuilder.buildPrompt(
      user: user,
      fridgeItems: fridgeItems,
      tools: tools,
      seasonings: seasonings,
      historyRecipes: historyRecipes,
      dishesCount: dishesCount,
      meatDishes: meatDishes,
      veggieDishes: veggieDishes,
      wantSoup: wantSoup,
      cookingTimeMinutes: cookingTimeMinutes,
      cuisineStyle: cuisineStyle,
    );

    // 4. 调用 API
    final result = await _api.generateMealPlan(prompt);

    // 5. 解析结果并保存到数据库
    await _savePlan(result, user);

    return result;
  }

  /// 生成剩余天数的菜谱（重排）
  Future<Map<String, dynamic>> regenerateRemainingDays({
    int startFromDay = 0,
    int dishesCount = 3,
    int meatDishes = 1,
    int veggieDishes = 2,
    bool wantSoup = true,
    int cookingTimeMinutes = 30,
    String cuisineStyle = '中餐',
  }) async {
    await _initAPI();

    final user = await _db.getUserProfile();
    if (user == null) throw Exception('请先完成个人资料设置');

    final fridgeItems = await _db.getIngredients();
    final kitchenItems = await _db.getKitchenItems();
    final tools = kitchenItems.where((i) => i.type == KitchenItemType.tool).toList();
    final seasonings = kitchenItems.where((i) => i.type == KitchenItemType.seasoning).toList();

    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    final now = DateTime.now().millisecondsSinceEpoch;
    final historyRecipes = await _db.getRecipesInDateRange(oneMonthAgo, now);

    final prompt = PromptBuilder.buildPrompt(
      user: user,
      fridgeItems: fridgeItems,
      tools: tools,
      seasonings: seasonings,
      historyRecipes: historyRecipes,
      dishesCount: dishesCount,
      meatDishes: meatDishes,
      veggieDishes: veggieDishes,
      wantSoup: wantSoup,
      cookingTimeMinutes: cookingTimeMinutes,
      cuisineStyle: cuisineStyle,
      startFromDay: startFromDay,
    );

    final result = await _api.generateMealPlan(prompt);

    // 删除旧计划中剩余天数的菜谱和采购清单
    final activePlan = await _db.getActivePlan();
    if (activePlan != null) {
      // 这些会被新结果覆盖（实际写入时替换）
    }

    await _savePlan(result, user);
    return result;
  }

  /// 保存解析后的菜谱到数据库
  Future<void> _savePlan(Map<String, dynamic> result, UserProfile user) async {
    final weekPlan = result['week_plan'] as Map<String, dynamic>?;
    if (weekPlan == null) throw Exception('返回数据格式错误：缺少 week_plan');

    // 先完成旧的活跃计划
    final activePlan = await _db.getActivePlan();
    if (activePlan != null) {
      await _db.updatePlanStatus(activePlan.id!, 'completed');
    }

    // 创建新计划
    final weekStart = DateTime.now().millisecondsSinceEpoch;
    final planConfig = jsonEncode({
      'dishes_count': 3, 'meat_dishes': 1, 'veggie_dishes': 2,
      'want_soup': true, 'cooking_time': 30, 'cuisine_style': '中餐',
    });
    final planId = await _db.addWeeklyPlan(WeeklyPlan(
      weekStart: weekStart,
      planConfig: planConfig,
    ));

    // 保存菜品
    final days = weekPlan['days'] as List? ?? [];
    for (final dayData in days) {
      final dayIndex = dayData['day'] as int? ?? 1;
      final meals = dayData['meals'] as List? ?? [];
      for (final meal in meals) {
        final ingredients = (meal['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [];
        await _db.addRecipe(Recipe(
          planId: planId,
          dayIndex: dayIndex - 1,
          mealType: meal['type'] as String? ?? '',
          name: meal['name'] as String? ?? '',
          description: meal['description'] as String? ?? '',
          calories: (meal['calories'] as num?)?.toDouble(),
          ingredientList: jsonEncode(ingredients),
        ));
      }
    }

    // 保存采购清单
    final shoppingList = weekPlan['shopping_list'] as List? ?? [];
    final shoppingItems = shoppingList.map((item) => ShoppingItem(
      planId: planId,
      name: item['name'] as String? ?? '',
      quantity: item['quantity'] as String? ?? '',
      source: 'plan',
    )).toList();
    if (shoppingItems.isNotEmpty) {
      await _db.addShoppingItems(shoppingItems);
    }
  }

  /// 处理调味料用完：加入采购清单
  Future<void> handleSeasoningOut(KitchenItem seasoning) async {
    await _db.updateKitchenItem(seasoning.copyWith(isAvailable: false));

    // 加到当前活跃计划的采购清单
    final activePlan = await _db.getActivePlan();
    if (activePlan != null) {
      final existingItems = await _db.getShoppingItems(activePlan.id!);
      final alreadyInList = existingItems.any((i) => i.name == seasoning.name && i.source == 'seasoning');
      if (!alreadyInList) {
        await _db.addShoppingItem(ShoppingItem(
          planId: activePlan.id!,
          name: seasoning.name,
          quantity: '1份',
          source: 'seasoning',
        ));
      }
    }
  }
}