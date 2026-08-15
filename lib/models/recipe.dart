// lib/models/recipe.dart
class Recipe {
  final int? id;
  final int planId;
  final int dayIndex; // 0-6
  final String mealType; // 早/午/晚
  final String name;
  final String description;
  final double? calories;
  final bool isFavorite;
  final String ingredientList; // 食材 JSON

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
  });

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
  );

  Recipe copyWith({bool? isFavorite}) => Recipe(
    id: id, planId: planId, dayIndex: dayIndex,
    mealType: mealType, name: name, description: description,
    calories: calories, ingredientList: ingredientList,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}