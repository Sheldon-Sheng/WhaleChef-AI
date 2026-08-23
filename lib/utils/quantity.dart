// lib/utils/quantity.dart
/// 解析数量文本，如 "2个"、"500g"；非数值（"适量"）返回 null
({double amount, String unit})? parseQuantity(String qty) {
  final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(qty.trim());
  if (match == null) return null;
  final amount = double.tryParse(match.group(1)!);
  if (amount == null) return null;
  return (amount: amount, unit: match.group(2)?.trim() ?? '');
}

/// 数值数量格式化为文本；amount<=0 视为「适量」
String formatQuantity(double amount, String unit) =>
    amount > 0
        ? (amount == amount.roundToDouble() ? '${amount.toInt()}$unit' : '$amount$unit')
        : (unit.isEmpty ? '适量' : unit);
