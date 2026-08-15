// lib/models/shopping_item.dart
class ShoppingItem {
  final int? id;
  final int planId;
  final String name;
  final String quantity;
  final String source; // 'plan' / 'seasoning'
  final bool purchased;

  ShoppingItem({
    this.id,
    required this.planId,
    required this.name,
    required this.quantity,
    this.source = 'plan',
    this.purchased = false,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'plan_id': planId,
    'name': name,
    'quantity': quantity,
    'source': source,
    'purchased': purchased ? 1 : 0,
  };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
    id: map['id'] as int?,
    planId: map['plan_id'] as int,
    name: map['name'] as String,
    quantity: map['quantity'] as String,
    source: map['source'] as String? ?? 'plan',
    purchased: (map['purchased'] as int?) == 1,
  );
}