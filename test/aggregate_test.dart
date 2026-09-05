// 聚合食材需求单测：同名相加、适量传播
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:deepfry/models/recipe.dart';
import 'package:deepfry/utils/quantity.dart';

void main() {
  test('aggregateRecipeIngredients 同名相加、适量传播', () {
    final r1 = Recipe(
      planId: 1,
      dayIndex: 0,
      mealType: '晚餐',
      name: 'A',
      ingredientList: jsonEncode([
        {'name': '牛肉', 'amount': 200, 'unit': 'g'},
        {'name': '盐', 'amount': null, 'unit': '适量'},
      ]),
    );
    final r2 = Recipe(
      planId: 1,
      dayIndex: 1,
      mealType: '晚餐',
      name: 'B',
      ingredientList: jsonEncode([
        {'name': '牛肉', 'amount': 300, 'unit': 'g'},
      ]),
    );
    final agg = aggregateRecipeIngredients([r1, r2]);
    expect(agg.where((n) => n.name == '牛肉').single.amount, 500);
    expect(agg.where((n) => n.name == '盐').single.amount, 0);
  });

  test('aggregateRecipeIngredients 任一适量则整名适量', () {
    final r1 = Recipe(
      planId: 1,
      dayIndex: 0,
      mealType: '晚餐',
      name: 'A',
      ingredientList: jsonEncode([
        {'name': '盐', 'amount': 100, 'unit': 'g'},
      ]),
    );
    final r2 = Recipe(
      planId: 1,
      dayIndex: 1,
      mealType: '晚餐',
      name: 'B',
      ingredientList: jsonEncode([
        {'name': '盐', 'amount': null, 'unit': '适量'},
      ]),
    );
    final agg = aggregateRecipeIngredients([r1, r2]);
    expect(agg.where((n) => n.name == '盐').single.amount, 0);
  });
}
