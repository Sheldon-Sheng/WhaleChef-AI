// lib/providers/kitchen_provider.dart
import 'package:flutter/foundation.dart';
import '../data/local_db.dart';
import '../models/kitchen_item.dart';
import '../services/meal_planner.dart';

class KitchenProvider extends ChangeNotifier {
  final LocalDB _db = LocalDB();
  final MealPlannerService _mealPlanner = MealPlannerService();
  List<KitchenItem> _items = [];
  bool _isLoading = false;

  List<KitchenItem> get items => _items;
  List<KitchenItem> get tools => _items.where((i) => i.type == KitchenItemType.tool).toList();
  List<KitchenItem> get seasonings => _items.where((i) => i.type == KitchenItemType.seasoning).toList();
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await _db.getKitchenItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(KitchenItem item) async {
    await _db.addKitchenItem(item);
    await loadItems();
  }

  Future<void> updateItem(KitchenItem item) async {
    await _db.updateKitchenItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _db.deleteKitchenItem(id);
    await loadItems();
  }

  /// 标记调味料为"无"，加入采购清单，返回是否建议重排（调味料变无时）
  Future<bool> setSeasoningUnavailable(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    await _db.updateKitchenItem(item.copyWith(isAvailable: false));
    await _mealPlanner.handleSeasoningOut(item);
    await loadItems();
    return true; // true = 建议重排
  }
}