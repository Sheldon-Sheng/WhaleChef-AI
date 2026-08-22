// lib/models/ingredient.dart
class Ingredient {
  final int? id;
  final String name;
  final double amount; // 数量数值
  final String unit;   // 单位，如 "个"、"g"、"份"
  final String? category;
  final int updatedAt;

  /// 兼容旧版：合并显示用
  String get quantity => amount == amount.roundToDouble()
      ? '${amount.toInt()}$unit'
      : '$amount$unit';

  Ingredient({
    this.id,
    required this.name,
    this.amount = 0,
    this.unit = '',
    this.category,
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  /// 从旧版 quantity 字符串解析（如 "5个"、"500g"、"适量"）
  factory Ingredient.fromQuantity(String name, String quantity, {String? category}) {
    final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(quantity.trim());
    if (match != null) {
      return Ingredient(
        name: name,
        amount: double.tryParse(match.group(1)!) ?? 0,
        unit: match.group(2)?.trim() ?? '',
        category: category,
      );
    }
    return Ingredient(name: name, amount: 0, unit: quantity, category: category);
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'amount': amount,
    'unit': unit,
    'category': category,
    'updated_at': updatedAt,
  };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    id: map['id'] as int?,
    name: map['name'] as String,
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    unit: map['unit'] as String? ?? '',
    category: map['category'] as String?,
    updatedAt: map['updated_at'] as int? ?? 0,
  );
}