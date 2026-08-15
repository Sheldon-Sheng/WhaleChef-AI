// lib/models/kitchen_item.dart
enum KitchenItemType { tool, seasoning }

class KitchenItem {
  final int? id;
  final KitchenItemType type;
  final String name;
  final bool isAvailable; // true=有, false=无

  KitchenItem({
    this.id,
    required this.type,
    required this.name,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'type': type.name,
    'name': name,
    'is_available': isAvailable ? 1 : 0,
  };

  factory KitchenItem.fromMap(Map<String, dynamic> map) => KitchenItem(
    id: map['id'] as int?,
    type: KitchenItemType.values.firstWhere((e) => e.name == map['type']),
    name: map['name'] as String,
    isAvailable: (map['is_available'] as int) == 1,
  );

  KitchenItem copyWith({bool? isAvailable}) => KitchenItem(
    id: id, type: type, name: name,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}