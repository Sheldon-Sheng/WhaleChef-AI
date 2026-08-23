// lib/services/meal_planner.dart
import 'dart:convert';

import '../data/local_db.dart';
import '../models/kitchen_item.dart';
import '../models/recipe.dart';
import '../models/weekly_plan.dart';
import '../models/shopping_item.dart';
import 'prompt_builder.dart';
import 'deepseek_api.dart';
import '../utils/quantity.dart';

class MealPlannerService {
  final LocalDB _db = LocalDB();
  late DeepSeekAPI _api;

  MealPlannerService();

  Future<void> _initAPI() async {
    final config = await _db.getAIConfig();
    _api = DeepSeekAPI(
      apiKey: config['api_key'] ?? '',
      model: config['model'] ?? 'deepseek-v4-flash',
      baseUrl: config['base_url'] ?? kDefaultAIBaseUrl,
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
    bool wantBreakfast = true,
    bool wantLunch = true,
    bool wantDinner = true,
    bool preferFavorites = false,
    int favoriteCount = 0,
  }) async {
    await _initAPI();

    // 1. 获取所有数据
    final user = await _db.getUserProfile();
    if (user == null) throw Exception('请先完成个人资料设置');

    final fridgeItems = await _db.getIngredients();
    final kitchenItems = await _db.getKitchenItems();
    final tools = kitchenItems
        .where((i) => i.type == KitchenItemType.tool)
        .toList();
    final seasonings = kitchenItems
        .where((i) => i.type == KitchenItemType.seasoning)
        .toList();

    // 2. 获取过去 1 个月的历史菜谱
    final oneMonthAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    final now = DateTime.now().millisecondsSinceEpoch;
    final historyRecipes = await _db.getRecipesInDateRange(oneMonthAgo, now);

    // 2b. 获取收藏菜谱
    List<Recipe> favoriteRecipes = [];
    if (preferFavorites && favoriteCount > 0) {
      favoriteRecipes = await _db.getFavoriteRecipes();
    }

    // 3. 组装 Prompt
    final prompt = PromptBuilder.buildPrompt(
      user: user,
      fridgeItems: fridgeItems,
      tools: tools,
      seasonings: seasonings,
      historyRecipes: historyRecipes,
      favoriteRecipes: favoriteRecipes,
      dishesCount: dishesCount,
      meatDishes: meatDishes,
      veggieDishes: veggieDishes,
      wantSoup: wantSoup,
      cookingTimeMinutes: cookingTimeMinutes,
      cuisineStyle: cuisineStyle,
      wantBreakfast: wantBreakfast,
      wantLunch: wantLunch,
      wantDinner: wantDinner,
      preferFavorites: preferFavorites,
      favoriteCount: favoriteCount,
    );

    // 4. 调用 API
    final result = await _api.generateMealPlan(prompt);

    // 5. 解析结果并保存到数据库
    await _savePlan(
      result,
      dishesCount: dishesCount,
      meatDishes: meatDishes,
      veggieDishes: veggieDishes,
      wantSoup: wantSoup,
      cookingTimeMinutes: cookingTimeMinutes,
      cuisineStyle: cuisineStyle,
    );

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
    bool wantBreakfast = true,
    bool wantLunch = true,
    bool wantDinner = true,
  }) async {
    await _initAPI();

    final user = await _db.getUserProfile();
    if (user == null) throw Exception('请先完成个人资料设置');

    final fridgeItems = await _db.getIngredients();
    final kitchenItems = await _db.getKitchenItems();
    final tools = kitchenItems
        .where((i) => i.type == KitchenItemType.tool)
        .toList();
    final seasonings = kitchenItems
        .where((i) => i.type == KitchenItemType.seasoning)
        .toList();

    final oneMonthAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
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
      wantBreakfast: wantBreakfast,
      wantLunch: wantLunch,
      wantDinner: wantDinner,
    );

    final result = await _api.generateMealPlan(prompt);

    // 删除旧活跃计划中剩余天数的菜谱和采购清单
    final activePlan = await _db.getActivePlan();
    if (activePlan != null) {
      await _db.deleteRecipesByPlanAndDayRange(activePlan.id!, startFromDay);
      await _db.deleteShoppingItemsByPlan(activePlan.id!);
      // 采购清单后续会由 _savePlan 根据新计划重新生成
    }

    await _savePlan(
      result,
      dishesCount: dishesCount,
      meatDishes: meatDishes,
      veggieDishes: veggieDishes,
      wantSoup: wantSoup,
      cookingTimeMinutes: cookingTimeMinutes,
      cuisineStyle: cuisineStyle,
    );
    return result;
  }

  /// 保存解析后的菜谱到数据库
  Future<void> _savePlan(
    Map<String, dynamic> result, {
    int dishesCount = 3,
    int meatDishes = 1,
    int veggieDishes = 2,
    bool wantSoup = true,
    int cookingTimeMinutes = 30,
    String cuisineStyle = '中餐',
  }) async {
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
      'dishes_count': dishesCount,
      'meat_dishes': meatDishes,
      'veggie_dishes': veggieDishes,
      'want_soup': wantSoup,
      'cooking_time': cookingTimeMinutes,
      'cuisine_style': cuisineStyle,
    });
    final planId = await _db.addWeeklyPlan(
      WeeklyPlan(weekStart: weekStart, planConfig: planConfig),
    );

    // 保存菜品
    final days = weekPlan['days'] as List? ?? [];
    for (final dayData in days) {
      final dayIndex = dayData['day'] as int? ?? 1;
      final meals = dayData['meals'] as List? ?? [];
      for (final meal in meals) {
        final rawIngredients = meal['ingredients'] as List? ?? [];
        final ingredients = rawIngredients.map((e) {
          final name = e is Map ? (e['name'] ?? '').toString() : e.toString();
          if (e is Map && (e['amount'] is num || e['quantity'] is String)) {
            if (e['amount'] is num) {
              return {
                'name': name,
                'amount': (e['amount'] as num).toDouble(),
                'unit': (e['unit'] ?? '').toString(),
              };
            }
            final parsed = parseQuantity((e['quantity'] ?? '').toString());
            return {
              'name': name,
              'amount': parsed?.amount ?? 0,
              'unit':
                  parsed?.unit ??
                  ((e['quantity'] ?? '').toString().isEmpty
                      ? '适量'
                      : (e['quantity'] ?? '').toString()),
            };
          }
          return {'name': name, 'amount': 0, 'unit': '适量'};
        }).toList();
        final seasonings =
            (meal['seasonings'] as List?)?.map((e) => e.toString()).toList() ??
            [];
        await _db.addRecipe(
          Recipe(
            planId: planId,
            dayIndex: dayIndex - 1,
            mealType: meal['type'] as String? ?? '',
            name: meal['name'] as String? ?? '',
            description: meal['description'] as String? ?? '',
            calories: (meal['calories'] as num?)?.toDouble(),
            ingredientList: jsonEncode(ingredients),
            seasoningList: jsonEncode(seasonings),
          ),
        );
      }
    }

    // 保存采购清单：周需求 − 冰箱存量（差量）
    final allRecipes = await _db.getRecipesByPlan(planId);
    final needs = aggregateRecipeIngredients(allRecipes);
    final shoppingItems = <ShoppingItem>[];
    for (final need in needs) {
      final fridge = await _db.getIngredientByName(need.name);
      final fridgeAmount = fridge?.amount ?? 0;
      final fridgeUnit = fridge?.unit ?? '';
      if (need.amount <= 0) {
        // 需求适量：原样加入采购
        shoppingItems.add(
          ShoppingItem(
            planId: planId,
            name: need.name,
            amount: 0,
            unit: need.unit,
            source: 'plan',
          ),
        );
      } else if (fridgeAmount > 0 &&
          fridgeUnit == need.unit &&
          fridgeAmount >= need.amount) {
        // 情况一：冰箱同单位且够，不买
        continue;
      } else {
        // 情况二：买差量（单位一致且不足 → 差量；无冰箱或单位不一致 → 全量）
        final shortfall = computeShoppingShortfall(
          need.amount,
          need.unit,
          fridgeAmount,
          fridgeUnit,
        );
        shoppingItems.add(
          ShoppingItem(
            planId: planId,
            name: need.name,
            amount: shortfall,
            unit: need.unit,
            source: 'plan',
          ),
        );
      }
    }
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
      final alreadyInList = existingItems.any(
        (i) => i.name == seasoning.name && i.source == 'seasoning',
      );
      if (!alreadyInList) {
        await _db.addShoppingItem(
          ShoppingItem(
            planId: activePlan.id!,
            name: seasoning.name,
            amount: 1,
            unit: '份',
            source: 'seasoning',
          ),
        );
      }
    }
  }
}
