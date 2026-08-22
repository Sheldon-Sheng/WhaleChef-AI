// 回归测试：ingredients 写路径不得依赖旧版 quantity 列（新库无此列）

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deepfry/data/local_db.dart';
import 'package:deepfry/models/ingredient.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    // 删除已有库文件，强制以全新 schema 创建，复现新安装场景
    final dbPath = '${await databaseFactory.getDatabasesPath()}/deepfry.db';
    final file = File(dbPath);
    if (file.existsSync()) file.deleteSync();
    await LocalDB().init();
  });

  test('saveIngredient 新增食材（购物确认购买路径）', () async {
    await LocalDB().saveIngredient('番茄', 3, '个');
    final ing = await LocalDB().getIngredientByName('番茄');
    expect(ing, isNotNull);
    expect(ing!.amount, 3);
    expect(ing.unit, '个');
  });

  test('addIngredient 通过 toMap 写入食材（冰箱添加路径）', () async {
    await LocalDB().addIngredient(Ingredient(name: '黄瓜', amount: 2, unit: '根'));
    final ing = await LocalDB().getIngredientByName('黄瓜');
    expect(ing, isNotNull);
    expect(ing!.amount, 2);
    expect(ing.unit, '根');
  });

  test('saveIngredient 更新已有食材数量', () async {
    await LocalDB().saveIngredient('番茄', 3, '个');
    await LocalDB().saveIngredient('番茄', 5, '个');
    final ing = await LocalDB().getIngredientByName('番茄');
    expect(ing, isNotNull);
    expect(ing!.amount, 5);
    expect(ing.unit, '个');
  });
}
