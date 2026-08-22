// lib/providers/meal_plan_provider.dart
import 'package:flutter/foundation.dart';
import '../data/local_db.dart';
import '../models/weekly_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner.dart';
import '../utils/quantity.dart';

enum GenerationStatus { idle, generating, success, failed }

class MealPlanProvider extends ChangeNotifier {
  final LocalDB _db = LocalDB();
  final MealPlannerService _mealPlanner = MealPlannerService();

  WeeklyPlan? _activePlan;
  List<Recipe> _currentRecipes = [];
  List<ShoppingItem> _shoppingItems = [];
  String? _errorMessage;
  GenerationStatus _status = GenerationStatus.idle;

  WeeklyPlan? get activePlan => _activePlan;
  List<Recipe> get currentRecipes => _currentRecipes;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  String? get errorMessage => _errorMessage;
  GenerationStatus get status => _status;

  Future<void> loadActivePlan() async {
    _activePlan = await _db.getActivePlan();
    final plan = _activePlan;
    if (plan != null) {
      _currentRecipes = await _db.getRecipesByPlan(plan.id!);
      _shoppingItems = await _db.getShoppingItems(plan.id!);
    }
    notifyListeners();
  }

  List<Recipe> getRecipesForDay(int dayIndex) {
    return _currentRecipes.where((r) => r.dayIndex == dayIndex).toList();
  }

  Future<void> generateWeekPlan({
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
    _status = GenerationStatus.generating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _mealPlanner.generateWeekPlan(
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
      await loadActivePlan();
      _status = GenerationStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = GenerationStatus.failed;
    }
    notifyListeners();
  }

  Future<void> regenerateRemainingDays(int startFromDay) async {
    _status = GenerationStatus.generating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _mealPlanner.regenerateRemainingDays(startFromDay: startFromDay);
      await loadActivePlan();
      _status = GenerationStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = GenerationStatus.failed;
    }
    notifyListeners();
  }

  Future<void> markPurchased(int itemId, String name, String quantity) async {
    await _db.markPurchased(itemId, name, quantity);
    await loadActivePlan();
  }

  /// 批量确认购买（单次事务，防止循环中列表变化）
  Future<void> batchMarkPurchased(List<({int itemId, String name, String quantity})> items) async {
    if (items.isEmpty) return;
    await _db.batchMarkPurchased(items);
    await loadActivePlan();
  }

  /// 重新加载 API 配置（用户修改设置后调用）
  Future<void> refreshAPIConfig() async {
    await _mealPlanner.refreshAPIConfig();
  }

  Future<void> toggleFavorite(int recipeId, bool isFavorite) async {
    await _db.toggleFavorite(recipeId, isFavorite);
    await loadActivePlan();
  }

  /// 确认完成今日烹饪：汇总今日食材需求，从冰箱优先扣除，不足从采购清单扣除
  Future<void> completeTodayCooking(int dayIndex) async {
    final plan = _activePlan;
    if (plan == null) return;
    final recipes = getRecipesForDay(dayIndex);
    if (recipes.isEmpty) return;

    // 汇总同名食材数量（数值相加、沿用首个单位；出现非数值则整体按「适量」）
    final needMap = <String, ({double amount, String unit, bool numeric})>{};
    final order = <String>[];
    for (final recipe in recipes) {
      for (final ing in recipe.ingredientItems) {
        // 跳过空/仅空白数量（旧数据遗留），避免误判为「适量」清空整条冰箱库存
        if (ing.quantity.trim().isEmpty) continue;
        final parsed = parseQuantity(ing.quantity);
        final cur = needMap[ing.name];
        if (parsed == null) {
          if (!needMap.containsKey(ing.name)) order.add(ing.name);
          needMap[ing.name] = (amount: 0, unit: ing.quantity, numeric: false);
        } else if (cur == null) {
          order.add(ing.name);
          needMap[ing.name] = (amount: parsed.amount, unit: parsed.unit, numeric: true);
        } else if (cur.numeric) {
          needMap[ing.name] = (amount: cur.amount + parsed.amount, unit: cur.unit, numeric: true);
        }
        // 已非数值则保持非数值
      }
    }

    final needs = order.map((name) {
      final n = needMap[name]!;
      return (name: name, quantity: n.numeric ? formatQuantity(n.amount, n.unit) : n.unit);
    }).toList();
    if (needs.isEmpty) return;

    await _db.consumeForCooking(plan.id!, needs);
    await loadActivePlan();
  }

  Future<void> deleteHistoryBefore(DateTime date) async {
    await _db.deletePlansBefore(date.millisecondsSinceEpoch);
    await loadActivePlan();
  }
}
