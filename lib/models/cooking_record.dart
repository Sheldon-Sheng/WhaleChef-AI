// lib/models/cooking_record.dart
import 'dart:convert';

/// 一次"已完成烹饪"记录的单项菜谱摘要。
class CookingRecordItem {
  final String name;
  final String mealType;
  final double calories;

  const CookingRecordItem({
    required this.name,
    required this.mealType,
    this.calories = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'mealType': mealType,
    'calories': calories,
  };

  factory CookingRecordItem.fromJson(Map<String, dynamic> m) =>
      CookingRecordItem(
        name: (m['name'] ?? '').toString(),
        mealType: (m['mealType'] ?? m['meal_type'] ?? '').toString(),
        calories: (m['calories'] as num?)?.toDouble() ?? 0,
      );
}

/// 每日烹饪记录(点「已完成今天的烹饪」时写入,按 record_date 幂等)。
class CookingRecord {
  final int? id;
  final int recordDate; // 当天零点毫秒(唯一,用于幂等覆盖)
  final int dayIndex; // 0-6
  final int weekStart; // 该周周一零点毫秒(= plan.weekStart)
  final double totalCalories; // 当日菜品卡路里合计
  final String recipeDetail; // JSON: [{name, mealType, calories}]
  final int createdAt;

  CookingRecord({
    this.id,
    required this.recordDate,
    required this.dayIndex,
    required this.weekStart,
    this.totalCalories = 0,
    this.recipeDetail = '[]',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// 解析当日菜谱摘要。
  List<CookingRecordItem> get recipeItems {
    if (recipeDetail.isEmpty) return const [];
    try {
      final list = jsonDecode(recipeDetail) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => CookingRecordItem.fromJson(e))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'record_date': recordDate,
    'day_index': dayIndex,
    'week_start': weekStart,
    'total_calories': totalCalories,
    'recipe_detail': recipeDetail,
    'created_at': createdAt,
  };

  factory CookingRecord.fromMap(Map<String, dynamic> map) => CookingRecord(
    id: map['id'] as int?,
    recordDate: map['record_date'] as int,
    dayIndex: map['day_index'] as int,
    weekStart: map['week_start'] as int,
    totalCalories: (map['total_calories'] as num?)?.toDouble() ?? 0,
    recipeDetail: map['recipe_detail'] as String? ?? '[]',
    createdAt: map['created_at'] as int? ?? 0,
  );
}
