// lib/models/ingredient.dart
class Ingredient {
  final int? id;
  final String name;
  final String quantity; // 文本格式，如 "12个"、"500g"
  final String? category; // 分类，可空
  final int updatedAt;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    this.category,
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'quantity': quantity,
    'category': category,
    'updated_at': updatedAt,
  };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    id: map['id'] as int?,
    name: map['name'] as String,
    quantity: map['quantity'] as String,
    category: map['category'] as String?,
    updatedAt: map['updated_at'] as int? ?? 0,
  );
}