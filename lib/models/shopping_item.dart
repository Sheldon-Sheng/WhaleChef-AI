// lib/models/shopping_item.dart
import '../utils/quantity.dart';

class ShoppingItem {
  final int? id;
  final int planId;
  final String name;
  final double amount; // 0 = 适量
  final String unit;
  final String source; // 'plan' / 'seasoning'
  final bool purchased;

  ShoppingItem({
    this.id,
    required this.planId,
    required this.name,
    this.amount = 0,
    this.unit = '',
    this.source = 'plan',
    this.purchased = false,
  });

  /// 展示用数量文本
  String get displayQuantity => formatQuantity(amount, unit);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'plan_id': planId,
    'name': name,
    'amount': amount,
    'unit': unit,
    'source': source,
    'purchased': purchased ? 1 : 0,
  };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
    id: map['id'] as int?,
    planId: map['plan_id'] as int,
    name: map['name'] as String,
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    unit: map['unit'] as String? ?? '',
    source: map['source'] as String? ?? 'plan',
    purchased: (map['purchased'] as int?) == 1,
  );
}
