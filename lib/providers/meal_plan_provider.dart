// lib/providers/meal_plan_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/local_db.dart';
import '../models/cooking_record.dart';
import '../models/weekly_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner.dart';
import '../utils/quantity.dart';
import '../l10n/app_error.dart';
import '../l10n/localized_error.dart';
import '../l10n/app_language.dart';

enum GenerationStatus { idle, generating, success, failed }

class MealPlanProvider extends ChangeNotifier {
  final LocalDB _db = LocalDB();
  final MealPlannerService _mealPlanner = MealPlannerService();

  WeeklyPlan? _activePlan;
  List<Recipe> _currentRecipes = [];
  List<ShoppingItem> _shoppingItems = [];
  Object? _error;
  GenerationStatus _status = GenerationStatus.idle;

  // 失败后的重试回调：记住最近一次「生成/重排」请求，重试时原样复用（避免丢失用户选择）
  Future<void> Function()? _retryAction;

  WeeklyPlan? get activePlan => _activePlan;
  List<Recipe> get currentRecipes => _currentRecipes;
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  String? get errorMessage {
    final e = _error;
    if (e is AppError) return localizeAppError(e);
    return e?.toString();
  }

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
    String? cuisineStyle,
    bool wantBreakfast = true,
    bool wantLunch = true,
    bool wantDinner = true,
    bool preferFavorites = false,
    int favoriteCount = 0,
  }) async {
    // 记录本次请求参数，供失败后「重试」复用（避免丢失用户选择）
    _retryAction = () => generateWeekPlan(
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

    _status = GenerationStatus.generating;
    _error = null;
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
        isEnglish: AppLanguage.isEnglish,
      );
      await loadActivePlan();
      _status = GenerationStatus.success;
    } catch (e) {
      _error = e;
      _status = GenerationStatus.failed;
    }
    notifyListeners();
  }

  /// 用最近一次「生成/重排」请求的参数原样重试（失败重试时使用，复用用户选择）。
  Future<void> retryLastGeneration() async {
    final action = _retryAction;
    if (action == null) return;
    await action();
  }

  Future<void> regenerateRemainingDays(int startFromDay) async {
    _retryAction = () => regenerateRemainingDays(startFromDay);
    _status = GenerationStatus.generating;
    _error = null;
    notifyListeners();

    try {
      await _mealPlanner.regenerateRemainingDays(
        startFromDay: startFromDay,
        isEnglish: AppLanguage.isEnglish,
      );
      await loadActivePlan();
      _status = GenerationStatus.success;
    } catch (e) {
      _error = e;
      _status = GenerationStatus.failed;
    }
    notifyListeners();
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

    // 记录当日菜谱与卡路里进烹饪历史（只要当天有菜谱就记录，不受食材是否为空影响）
    final totalCalories = recipes.fold<double>(
      0,
      (s, r) => s + (r.calories ?? 0),
    );
    final base = DateTime.fromMillisecondsSinceEpoch(plan.weekStart);
    final recordDate = DateTime(base.year, base.month, base.day + dayIndex);
    final detail = recipes
        .map(
          (r) => <String, dynamic>{
            'name': r.name,
            'mealType': r.mealType,
            'calories': r.calories ?? 0,
          },
        )
        .toList();
    await _db.saveCookingRecord(
      CookingRecord(
        recordDate: recordDate.millisecondsSinceEpoch,
        dayIndex: dayIndex,
        weekStart: plan.weekStart,
        totalCalories: totalCalories,
        recipeDetail: jsonEncode(detail),
      ),
    );

    final needs = aggregateRecipeIngredients(recipes);
    if (needs.isEmpty) return;

    await _db.consumeForCooking(plan.id!, needs);
    await loadActivePlan();
  }

  Future<void> deleteHistoryBefore(DateTime date) async {
    await _db.deletePlansBefore(date.millisecondsSinceEpoch);
    await loadActivePlan();
  }
}
