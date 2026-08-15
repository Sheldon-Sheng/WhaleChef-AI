// lib/providers/fridge_provider.dart
import 'package:flutter/foundation.dart';
import '../data/local_db.dart';
import '../models/ingredient.dart';

class FridgeProvider extends ChangeNotifier {
  final LocalDB _db = LocalDB();
  List<Ingredient> _items = [];
  bool _isLoading = false;

  List<Ingredient> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await _db.getIngredients();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(Ingredient item) async {
    await _db.addIngredient(item);
    await loadItems();
  }

  Future<void> updateItem(Ingredient item) async {
    await _db.updateIngredient(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _db.deleteIngredient(id);
    await loadItems();
  }

  Future<void> updateQuantity(int id, String newQuantity) async {
    await _db.updateIngredientQuantity(id, newQuantity);
    await loadItems();
  }
}