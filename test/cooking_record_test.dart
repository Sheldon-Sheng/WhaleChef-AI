// 烹饪记录与每周卡路里统计测试
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deepfry/data/local_db.dart';
import 'package:deepfry/models/cooking_record.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    // 独立库文件，避免与其他测试并行争用
    final dbPath =
        '${await databaseFactory.getDatabasesPath()}/deepfry_cooking_record_test.db';
    final file = File(dbPath);
    if (file.existsSync()) file.deleteSync();
    await LocalDB().init(path: dbPath);
  });

  setUp(() async {
    final db = LocalDB().db;
    await db.delete('cooking_records');
    await db.delete('weekly_plans');
  });

  int dayMillis(int y, int m, int d) =>
      DateTime(y, m, d).millisecondsSinceEpoch;

  test('getWeeklyCalories 按周一小组求和并升序', () async {
    final db = LocalDB();
    final week1 = dayMillis(2026, 8, 3); // 周一
    final week2 = dayMillis(2026, 8, 10); // 周一

    // week1：周一100 + 周二200 + 周三150 = 450
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 3),
        dayIndex: 0,
        weekStart: week1,
        totalCalories: 100,
      ),
    );
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 4),
        dayIndex: 1,
        weekStart: week1,
        totalCalories: 200,
      ),
    );
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 5),
        dayIndex: 2,
        weekStart: week1,
        totalCalories: 150,
      ),
    );
    // week2：周一50 + 周四300 = 350
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 10),
        dayIndex: 0,
        weekStart: week2,
        totalCalories: 50,
      ),
    );
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 13),
        dayIndex: 3,
        weekStart: week2,
        totalCalories: 300,
      ),
    );

    final weekly = await db.getWeeklyCalories();
    expect(weekly.length, 2);
    expect(weekly[0].weekStart, week1);
    expect(weekly[0].total, 450);
    expect(weekly[1].weekStart, week2);
    expect(weekly[1].total, 350);
  });

  test('saveCookingRecord 同 record_date 幂等覆盖', () async {
    final db = LocalDB();
    final ws = dayMillis(2026, 8, 3);
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 4),
        dayIndex: 1,
        weekStart: ws,
        totalCalories: 100,
      ),
    );
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 4),
        dayIndex: 1,
        weekStart: ws,
        totalCalories: 999,
      ),
    );

    final records = await db.getCookingRecords();
    expect(records.length, 1);
    expect(records.first.totalCalories, 999);
    // 周统计应只有一根柱
    final weekly = await db.getWeeklyCalories();
    expect(weekly.length, 1);
  });

  test('CookingRecord.recipeItems 解析菜谱摘要', () {
    final record = CookingRecord(
      recordDate: dayMillis(2026, 8, 3),
      dayIndex: 0,
      weekStart: dayMillis(2026, 8, 3),
      recipeDetail:
          '[{"name":"粥","mealType":"早餐","calories":120},'
          '{"name":"番茄炒蛋","mealType":"午餐","calories":300}]',
    );
    final items = record.recipeItems;
    expect(items.length, 2);
    expect(items[0].name, '粥');
    expect(items[0].calories, 120);
    expect(items[1].mealType, '午餐');
  });

  test('deletePlansBefore 级联删除早于日期的 cooking_records', () async {
    final db = LocalDB();
    final ws = dayMillis(2026, 8, 3);
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 7, 1),
        dayIndex: 0,
        weekStart: ws,
        totalCalories: 100,
      ),
    ); // 早于阈值
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 15),
        dayIndex: 0,
        weekStart: ws,
        totalCalories: 200,
      ),
    ); // 晚于阈值

    await db.deletePlansBefore(dayMillis(2026, 8, 1));

    final records = await db.getCookingRecords();
    expect(records.length, 1);
    expect(records.first.totalCalories, 200);
  });

  test('getLastWeekDishNames 只返回最近一周的菜名', () async {
    final db = LocalDB();
    final week1 = dayMillis(2026, 8, 3);
    final week2 = dayMillis(2026, 8, 10);
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 3),
        dayIndex: 0,
        weekStart: week1,
        totalCalories: 100,
        recipeDetail: '[{"name":"粥","mealType":"早餐","calories":100}]',
      ),
    );
    await db.saveCookingRecord(
      CookingRecord(
        recordDate: dayMillis(2026, 8, 10),
        dayIndex: 0,
        weekStart: week2,
        totalCalories: 200,
        recipeDetail: '[{"name":"番茄炒蛋","mealType":"午餐","calories":200}]',
      ),
    );
    final names = await db.getLastWeekDishNames();
    expect(names, ['番茄炒蛋']);
  });
}
