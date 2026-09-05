// 回归测试：ingredients 写路径不得依赖旧版 quantity 列（新库无此列）

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deepfry/data/local_db.dart';
import 'package:deepfry/models/ingredient.dart';
import 'package:deepfry/models/weekly_plan.dart';
import 'package:deepfry/models/recipe.dart';
import 'package:deepfry/models/shopping_item.dart';
import 'package:deepfry/models/kitchen_item.dart';
import 'package:deepfry/models/user_profile.dart';
import 'package:deepfry/models/cooking_record.dart';

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

  test('addToIngredientStock 已有食材累加存量', () async {
    await LocalDB().saveIngredient('牛肉', 300, 'g');
    final ing = await LocalDB().getIngredientByName('牛肉');
    await LocalDB().addToIngredientStock(ing!.id!, 200, 'g');
    final updated = await LocalDB().getIngredientByName('牛肉');
    expect(updated, isNotNull);
    expect(updated!.amount, 500);
    expect(updated.unit, 'g');
  });

  test('addToIngredientStock amount<=0 不累加（适量）', () async {
    await LocalDB().saveIngredient('盐', 0, '适量');
    final ing = await LocalDB().getIngredientByName('盐');
    await LocalDB().addToIngredientStock(ing!.id!, 0, '适量');
    final updated = await LocalDB().getIngredientByName('盐');
    expect(updated, isNotNull);
    expect(updated!.amount, 0);
    expect(updated.unit, '适量');
  });

  test('clearAllIngredients 清空冰箱', () async {
    await LocalDB().saveIngredient('番茄', 3, '个');
    await LocalDB().saveIngredient('黄瓜', 2, '根');
    await LocalDB().clearAllIngredients();
    expect(await LocalDB().getIngredients(), isEmpty);
  });

  test('未配置 AI 时 base_url 为空（无默认值）', () async {
    final config = await LocalDB().getAIConfig();
    expect(config['base_url'], '');
  });

  test('AI 配置保存/读取 round-trip 含 base_url', () async {
    await LocalDB().saveAIConfig(
      'test-key',
      'test-model',
      'https://api.openai.com/v1',
    );
    final config = await LocalDB().getAIConfig();
    expect(config['api_key'], 'test-key');
    expect(config['model'], 'test-model');
    expect(config['base_url'], 'https://api.openai.com/v1');
  });

  test('clearUserGeneratedData 语言切换清空用户数据，保留工具/资料/配置', () async {
    final db = LocalDB();

    // 种子数据
    final planId = await db.addWeeklyPlan(
      WeeklyPlan(weekStart: 1, planConfig: '{}'),
    );
    await db.addRecipe(
      Recipe(planId: planId, dayIndex: 0, mealType: '早餐', name: '粥'),
    );
    await db.addShoppingItem(
      ShoppingItem(planId: planId, name: '番茄', amount: 2, unit: '个'),
    );
    await db.saveIngredient('番茄', 2, '个');
    await db.addKitchenItem(
      KitchenItem(type: KitchenItemType.tool, name: '菜刀'),
    );
    await db.addKitchenItem(
      KitchenItem(type: KitchenItemType.seasoning, name: '盐'),
    );
    await db.saveUserProfile(
      UserProfile(
        age: 25,
        gender: '男',
        height: 170,
        weight: 65,
        targetWeight: 60,
        targetBodyFat: 20,
      ),
    );
    await db.saveAIConfig('k', 'm', 'https://api.deepseek.com/v1');
    // 烹饪记录属历史日志，语言切换时保留
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: DateTime(2026, 8, 3).millisecondsSinceEpoch,
        dayIndex: 0,
        weekStart: DateTime(2026, 8, 3).millisecondsSinceEpoch,
        totalCalories: 120,
      ),
    );

    await db.clearUserGeneratedData();

    // 菜谱/采购/计划清空
    expect(await db.getActivePlan(), isNull);
    expect(await db.getRecipesByPlan(planId), isEmpty);
    expect(await db.getShoppingItems(planId), isEmpty);
    // 冰箱食材清空
    expect(await db.getIngredients(), isEmpty);
    // 调味料清空，但厨具保留
    expect(await db.getKitchenItems(type: 'seasoning'), isEmpty);
    expect((await db.getKitchenItems(type: 'tool')).length, 1);
    // 保留 user_profile / ai_config
    expect(await db.getUserProfile(), isNotNull);
    expect((await db.getAIConfig())['api_key'], 'k');
    // 烹饪历史保留
    expect((await db.getCookingRecords()).length, 1);
  });

  test('UserProfile allergens 往返', () async {
    await LocalDB().saveUserProfile(
      UserProfile(
        age: 30,
        gender: '男',
        height: 170,
        weight: 60,
        targetWeight: 55,
        targetBodyFat: 18,
        allergens: '花生,虾',
      ),
    );
    final u = await LocalDB().getUserProfile();
    expect(u!.allergens, '花生,虾');
  });
}
