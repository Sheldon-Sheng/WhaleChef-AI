// lib/providers/meal_plan_provider.dart
import 'package:flutter/foundation.dart';
import '../data/local_db.dart';
import '../models/weekly_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../services/meal_planner.dart';

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

  Future<void> toggleFavorite(int recipeId, bool isFavorite) async {
    await _db.toggleFavorite(recipeId, isFavorite);
    await loadActivePlan();
  }

  Future<void> deleteHistoryBefore(DateTime date) async {
    await _db.deletePlansBefore(date.millisecondsSinceEpoch);
    await loadActivePlan();
  }
}