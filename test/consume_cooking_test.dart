// 完成烹饪扣除逻辑测试：冰箱优先、采购兜底、归零删除
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deepfry/data/local_db.dart';
import 'package:deepfry/models/weekly_plan.dart';
import 'package:deepfry/models/shopping_item.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    // 独立库文件，避免与 local_db_test 并行时争用同一 deepfry.db
    final dbPath = '${await databaseFactory.getDatabasesPath()}/deepfry_consume_test.db';
    final file = File(dbPath);
    if (file.existsSync()) file.deleteSync();
    await LocalDB().init(path: dbPath);
  });

  Future<int> makePlan() =>
      LocalDB().addWeeklyPlan(WeeklyPlan(weekStart: 1));

  // 每条测试独立数据：清空购物清单、冰箱与周计划，避免跨用例残留干扰
  setUp(() async {
    final db = LocalDB().db;
    await db.delete('shopping_items');
    await db.delete('ingredients');
    await db.delete('weekly_plans');
  });

  test('情况一：冰箱足够则从冰箱扣除，归零删除', () async {
    final planId = await makePlan();
    await LocalDB().saveIngredient('番茄', 5, '个');
    await LocalDB().addShoppingItems([ShoppingItem(planId: planId, name: '番茄', amount: 2, unit: '个')]);

    await LocalDB().consumeForCooking(planId, [(name: '番茄', amount: 3, unit: '个')]);

    final ing = await LocalDB().getIngredientByName('番茄');
    expect(ing!.amount, 2); // 5 - 3
    final shop = await LocalDB().getShoppingItems(planId);
    expect(shop.where((s) => s.name == '番茄'), hasLength(1)); // 采购不动
  });

  test('情况一：扣除后为 0 则删除冰箱条目', () async {
    final planId = await makePlan();
    await LocalDB().saveIngredient('番茄', 3, '个');
    await LocalDB().consumeForCooking(planId, [(name: '番茄', amount: 3, unit: '个')]);
    expect(await LocalDB().getIngredientByName('番茄'), isNull);
  });

  test('情况二：冰箱没有则从采购清单扣除，归零删除', () async {
    final planId = await makePlan();
    await LocalDB().addShoppingItems([ShoppingItem(planId: planId, name: '土豆', amount: 5, unit: '个')]);

    await LocalDB().consumeForCooking(planId, [(name: '土豆', amount: 5, unit: '个')]);

    final shop = await LocalDB().getShoppingItems(planId);
    expect(shop.where((s) => s.name == '土豆'), isEmpty);
  });

  test('情况二：采购清单扣减后剩余则写回数量', () async {
    final planId = await makePlan();
    await LocalDB().addShoppingItems([ShoppingItem(planId: planId, name: '土豆', amount: 5, unit: '个')]);

    await LocalDB().consumeForCooking(planId, [(name: '土豆', amount: 2, unit: '个')]);

    final shop = await LocalDB().getShoppingItems(planId);
    expect(shop.where((s) => s.name == '土豆').single.displayQuantity, '3个');
  });

  test('情况三：冰箱部分则扣光冰箱，不足部分从采购扣除', () async {
    final planId = await makePlan();
    await LocalDB().saveIngredient('番茄', 1, '个');
    await LocalDB().addShoppingItems([ShoppingItem(planId: planId, name: '番茄', amount: 4, unit: '个')]);

    await LocalDB().consumeForCooking(planId, [(name: '番茄', amount: 3, unit: '个')]);

    expect(await LocalDB().getIngredientByName('番茄'), isNull);
    final shop = await LocalDB().getShoppingItems(planId);
    expect(shop.where((s) => s.name == '番茄').single.displayQuantity, '2个'); // 4 - (3-1)
  });

  test('「适量」非数值：用完当前可用整条', () async {
    final planId = await makePlan();
    await LocalDB().saveIngredient('番茄', 2, '个');
    await LocalDB().addShoppingItems([ShoppingItem(planId: planId, name: '番茄', amount: 3, unit: '个')]);

    await LocalDB().consumeForCooking(planId, [(name: '番茄', amount: 0, unit: '适量')]);

    expect(await LocalDB().getIngredientByName('番茄'), isNull); // 冰箱整条用完
    final shop = await LocalDB().getShoppingItems(planId);
    expect(shop.where((s) => s.name == '番茄'), hasLength(1)); // 采购不动
  });
}
