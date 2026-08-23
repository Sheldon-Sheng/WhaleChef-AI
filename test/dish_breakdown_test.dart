// 菜谱荤素配比推导：素菜 = 总菜数 − 荤菜数，荤菜夹在 [0, 总数]
import 'package:flutter_test/flutter_test.dart';
import 'package:deepfry/utils/dish_count.dart';

void main() {
  test('1 道菜 1 荤 → 0 素（不再默认 2 素）', () {
    final b = computeDishBreakdown(1, 1);
    expect(b.meat, 1);
    expect(b.veggie, 0);
  });

  test('3 道菜 1 荤 → 2 素', () {
    final b = computeDishBreakdown(3, 1);
    expect(b.meat, 1);
    expect(b.veggie, 2);
  });

  test('荤菜超过总数时夹到总数，素菜为 0', () {
    final b = computeDishBreakdown(2, 3);
    expect(b.meat, 2);
    expect(b.veggie, 0);
  });

  test('荤菜为 0 时全素', () {
    final b = computeDishBreakdown(3, 0);
    expect(b.meat, 0);
    expect(b.veggie, 3);
  });

  test('荤菜为负时视为 0', () {
    final b = computeDishBreakdown(3, -1);
    expect(b.meat, 0);
    expect(b.veggie, 3);
  });
}
