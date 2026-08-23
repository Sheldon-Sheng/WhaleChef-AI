// lib/models/recipe.dart
import 'dart:convert';

/// 菜谱中的一种食材（统一结构化数量；amount=0 为适量）
class RecipeIngredient {
  final String name;
  final double amount;
  final String unit;
  const RecipeIngredient({required this.name, this.amount = 0, this.unit = ''});

  /// 展示文本
  String get displayQuantity =>
      amount > 0 ? (amount == amount.roundToDouble() ? '${amount.toInt()}$unit' : '$amount$unit') : (unit.isEmpty ? '适量' : unit);
}

class Recipe {
  final int? id;
  final int planId;
  final int dayIndex; // 0-6
  final String mealType; // 早/午/晚
  final String name;
  final String description;
  final double? calories;
  final bool isFavorite;
  final String ingredientList; // 食材 JSON: [{"name","amount","unit"}]
  final String seasoningList;  // 调味品 JSON: ["盐"]

  Recipe({
    this.id,
    required this.planId,
    required this.dayIndex,
    required this.mealType,
    required this.name,
    this.description = '',
    this.calories,
    this.isFavorite = false,
    this.ingredientList = '[]',
    this.seasoningList = '[]',
  });

  /// 解析食材（仅新格式 amount/unit；解析失败返回空）
  List<RecipeIngredient> get ingredientItems {
    if (ingredientList.isEmpty) return const [];
    try {
      final list = jsonDecode(ingredientList) as List;
      return list.whereType<Map>().map((e) {
        return RecipeIngredient(
          name: (e['name'] ?? '').toString(),
          amount: (e['amount'] as num?)?.toDouble() ?? 0,
          unit: (e['unit'] ?? '').toString(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// 解析调味品
  List<String> get seasoningItems {
    if (seasoningList.isEmpty) return const [];
    try {
      return (jsonDecode(seasoningList) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'plan_id': planId,
    'day_index': dayIndex,
    'meal_type': mealType,
    'name': name,
    'description': description,
    'calories': calories,
    'is_favorite': isFavorite ? 1 : 0,
    'ingredient_list': ingredientList,
    'seasoning_list': seasoningList,
  };

  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
    id: map['id'] as int?,
    planId: map['plan_id'] as int,
    dayIndex: map['day_index'] as int,
    mealType: map['meal_type'] as String,
    name: map['name'] as String,
    description: map['description'] as String? ?? '',
    calories: map['calories'] as double?,
    isFavorite: (map['is_favorite'] as int?) == 1,
    ingredientList: map['ingredient_list'] as String? ?? '[]',
    seasoningList: map['seasoning_list'] as String? ?? '[]',
  );

  Recipe copyWith({bool? isFavorite, String? seasoningList}) => Recipe(
    id: id, planId: planId, dayIndex: dayIndex,
    mealType: mealType, name: name, description: description,
    calories: calories, ingredientList: ingredientList,
    seasoningList: seasoningList ?? this.seasoningList,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
