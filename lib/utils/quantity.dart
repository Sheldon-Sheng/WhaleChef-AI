// lib/utils/quantity.dart
import '../models/recipe.dart';
import '../l10n/app_language.dart';

/// 解析数量文本，如 "2个"、"500g"；非数值（"适量"）返回 null
({double amount, String unit})? parseQuantity(String qty) {
  final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(qty.trim());
  if (match == null) return null;
  final amount = double.tryParse(match.group(1)!);
  if (amount == null) return null;
  return (amount: amount, unit: match.group(2)?.trim() ?? '');
}

/// 「适量」在当前语言下的文案
String get asNeededLabel => AppLanguage.isEnglish ? 'as needed' : '适量';

/// 数值数量格式化为文本；amount<=0 视为「适量 / as needed」
/// 中文保持字节级不变(如 "3个"、无空格)；英文加空格(如 "3 pc")
String formatQuantity(double amount, String unit) {
  if (amount > 0) {
    final s = amount == amount.roundToDouble()
        ? '${amount.toInt()}'
        : '$amount';
    return AppLanguage.isEnglish ? '$s $unit' : '$s$unit';
  }
  if (unit.isNotEmpty && unit != asNeededLabel) return unit;
  return asNeededLabel;
}

/// 计算采购差量：仅当冰箱单位与需求单位一致时才扣减存量；冰箱足够→0；否则全量
double computeShoppingShortfall(
  double needAmount,
  String needUnit,
  double fridgeAmount,
  String fridgeUnit,
) {
  if (needAmount <= 0) return needAmount;
  if (fridgeAmount > 0 &&
      fridgeUnit == needUnit &&
      fridgeAmount >= needAmount) {
    return 0;
  }
  if (fridgeAmount > 0 && fridgeUnit == needUnit) {
    return needAmount - fridgeAmount;
  }
  return needAmount; // 无冰箱或单位不一致 → 全量
}

/// 聚合多个菜谱的食材需求：同名 amount 相加（沿用首个 unit）；任一为适量则该名整体适量
List<({String name, double amount, String unit})> aggregateRecipeIngredients(
  List<Recipe> recipes,
) {
  final map = <String, ({double amount, String unit, bool numeric})>{};
  final order = <String>[];
  for (final recipe in recipes) {
    for (final ing in recipe.ingredientItems) {
      final cur = map[ing.name];
      if (ing.amount <= 0) {
        if (!map.containsKey(ing.name)) order.add(ing.name);
        map[ing.name] = (amount: 0, unit: ing.unit, numeric: false);
      } else if (cur == null) {
        order.add(ing.name);
        map[ing.name] = (amount: ing.amount, unit: ing.unit, numeric: true);
      } else if (cur.numeric) {
        map[ing.name] = (
          amount: cur.amount + ing.amount,
          unit: cur.unit,
          numeric: true,
        );
      }
    }
  }
  return order.map((name) {
    final n = map[name]!;
    return (
      name: name,
      amount: n.amount,
      unit: n.numeric ? n.unit : (n.unit.isEmpty ? asNeededLabel : n.unit),
    );
  }).toList();
}
