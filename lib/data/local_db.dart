// lib/data/local_db.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user_profile.dart';
import '../models/ingredient.dart';
import '../models/kitchen_item.dart';
import '../models/weekly_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../models/cooking_record.dart';

class LocalDB {
  static final LocalDB _instance = LocalDB._internal();
  factory LocalDB() => _instance;
  LocalDB._internal();

  Database? _db;
  Database get db => _db!;

  Future<void> init({String? path}) async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      path ?? join(dbPath, 'deepfry.db'),
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 确保 amount/unit 列存在（老库可能缺少）
      final cols = await db.rawQuery('PRAGMA table_info(ingredients)');
      final colNames = cols.map((c) => c['name']).toSet();
      if (!colNames.contains('amount')) {
        await db.execute(
          'ALTER TABLE ingredients ADD COLUMN amount REAL DEFAULT 0',
        );
      }
      if (!colNames.contains('unit')) {
        await db.execute(
          'ALTER TABLE ingredients ADD COLUMN unit TEXT DEFAULT ""',
        );
      }
      // 解析已有 quantity 数据并填入 amount/unit（若 amount 为 0）
      final rows = await db.query('ingredients');
      for (final row in rows) {
        final qty = row['quantity'] as String? ?? '';
        final curAmount = row['amount'] as num? ?? 0;
        if (curAmount == 0 && qty.isNotEmpty) {
          final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(qty.trim());
          if (match != null) {
            final amount = double.tryParse(match.group(1)!) ?? 0;
            final unit = match.group(2)?.trim() ?? '';
            await db.update(
              'ingredients',
              {'amount': amount, 'unit': unit},
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          } else {
            await db.update(
              'ingredients',
              {'amount': 0, 'unit': qty},
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
        } else if (curAmount == 0) {
          await db.update(
            'ingredients',
            {'unit': qty},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      }
    }
    if (oldVersion < 3) {
      // v2→v3: recipes 加 seasoning_list 列（仅 schema 演进）
      final cols = await db.rawQuery('PRAGMA table_info(recipes)');
      final colNames = cols.map((c) => c['name']).toSet();
      if (!colNames.contains('seasoning_list')) {
        await db.execute(
          'ALTER TABLE recipes ADD COLUMN seasoning_list TEXT DEFAULT "[]"',
        );
      }
    }
    if (oldVersion < 4) {
      // v4: 统一结构化数量（amount+unit），直接清空旧数据
      await db.execute('DROP TABLE IF EXISTS shopping_items');
      await db.execute('''CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT '',
        source TEXT DEFAULT 'plan',
        purchased INTEGER DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES weekly_plans(id) ON DELETE CASCADE
      )''');
      await db.delete('ingredients');
      await db.delete('shopping_items');
      await db.delete('recipes');
      await db.delete('weekly_plans');
    }
    if (oldVersion < 5) {
      // v4→v5: ai_config 加 base_url 列（支持自定义 AI 地址）
      final cols = await db.rawQuery('PRAGMA table_info(ai_config)');
      final colNames = cols.map((c) => c['name']).toSet();
      if (!colNames.contains('base_url')) {
        await db.execute(
          'ALTER TABLE ai_config ADD COLUMN base_url TEXT NOT NULL DEFAULT ""',
        );
      }
    }
    if (oldVersion < 6) {
      // v5→v6: 新增烹饪记录表（完成烹饪时按天记录，用于每周卡路里统计）
      await db.execute('''
        CREATE TABLE cooking_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          record_date INTEGER NOT NULL UNIQUE,
          day_index INTEGER NOT NULL,
          week_start INTEGER NOT NULL,
          total_calories REAL NOT NULL DEFAULT 0,
          recipe_detail TEXT NOT NULL DEFAULT '[]',
          created_at INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 7) {
      // v6→v7: user_profile 加 allergens（过敏的食物）
      final cols = await db.rawQuery('PRAGMA table_info(user_profile)');
      final colNames = cols.map((c) => c['name']).toSet();
      if (!colNames.contains('allergens')) {
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN allergens TEXT DEFAULT ""',
        );
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        body_fat_rate REAL,
        health_report_notes TEXT,
        chronic_diseases TEXT,
        target_weight REAL NOT NULL,
        target_body_fat REAL NOT NULL,
        preferred_foods TEXT DEFAULT '',
        disliked_foods TEXT DEFAULT '',
        allergens TEXT DEFAULT '',
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT '',
        category TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE kitchen_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        is_available INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE weekly_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start INTEGER NOT NULL,
        plan_config TEXT DEFAULT '{}',
        status TEXT DEFAULT 'active',
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        day_index INTEGER NOT NULL,
        meal_type TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        calories REAL,
        is_favorite INTEGER DEFAULT 0,
        ingredient_list TEXT DEFAULT '[]',
        seasoning_list TEXT DEFAULT '[]',
        FOREIGN KEY (plan_id) REFERENCES weekly_plans(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT '',
        source TEXT DEFAULT 'plan',
        purchased INTEGER DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES weekly_plans(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE ai_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        api_key TEXT NOT NULL DEFAULT '',
        model TEXT NOT NULL DEFAULT 'deepseek-v4-flash',
        base_url TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE cooking_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        record_date INTEGER NOT NULL UNIQUE,
        day_index INTEGER NOT NULL,
        week_start INTEGER NOT NULL,
        total_calories REAL NOT NULL DEFAULT 0,
        recipe_detail TEXT NOT NULL DEFAULT '[]',
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // === User Profile ===
  Future<UserProfile?> getUserProfile() async {
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final existing = await getUserProfile();
    if (existing != null) {
      await db.update(
        'user_profile',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      await db.insert('user_profile', profile.toMap());
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // === Ingredients ===
  Future<List<Ingredient>> getIngredients() async {
    final maps = await db.query('ingredients', orderBy: 'updated_at DESC');
    return maps.map((m) => Ingredient.fromMap(m)).toList();
  }

  Future<Ingredient?> getIngredientByName(String name) async {
    final maps = await db.query(
      'ingredients',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Ingredient.fromMap(maps.first);
  }

  Future<void> saveIngredient(String name, double amount, String unit) async {
    final existing = await getIngredientByName(name);
    if (existing != null) {
      await db.update(
        'ingredients',
        {
          'amount': amount,
          'unit': unit,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      await db.insert('ingredients', {
        'name': name,
        'amount': amount,
        'unit': unit,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> deleteShoppingItem(int itemId) async {
    await db.delete('shopping_items', where: 'id = ?', whereArgs: [itemId]);
  }

  Future<int> addIngredient(Ingredient item) async {
    return await db.insert('ingredients', item.toMap());
  }

  Future<void> updateIngredient(Ingredient item) async {
    await db.update(
      'ingredients',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteIngredient(int id) async {
    await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateIngredientQuantity(
    int id,
    double amount,
    String unit,
  ) async {
    await db.update(
      'ingredients',
      {
        'amount': amount,
        'unit': unit,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 冰箱已有食材时累加存量（amount<=0 视为适量，不累加数值）
  Future<void> addToIngredientStock(int id, double amount, String unit) async {
    if (amount <= 0) return;
    final rows = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final existingAmount = (rows.first['amount'] as num?)?.toDouble() ?? 0;
    await db.update(
      'ingredients',
      {
        'amount': existingAmount + amount,
        'unit': unit,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 清空冰箱
  Future<void> clearAllIngredients() async {
    await db.delete('ingredients');
  }

  // === Kitchen Items ===
  Future<List<KitchenItem>> getKitchenItems({String? type}) async {
    final where = type != null ? 'type = ?' : null;
    final whereArgs = type != null ? [type] : null;
    final maps = await db.query(
      'kitchen_items',
      where: where,
      whereArgs: whereArgs,
    );
    return maps.map((m) => KitchenItem.fromMap(m)).toList();
  }

  Future<int> addKitchenItem(KitchenItem item) async {
    return await db.insert('kitchen_items', item.toMap());
  }

  Future<void> updateKitchenItem(KitchenItem item) async {
    await db.update(
      'kitchen_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteKitchenItem(int id) async {
    await db.delete('kitchen_items', where: 'id = ?', whereArgs: [id]);
  }

  // === Weekly Plans ===
  Future<int> addWeeklyPlan(WeeklyPlan plan) async {
    return await db.insert('weekly_plans', plan.toMap());
  }

  Future<List<WeeklyPlan>> getWeeklyPlans({String? status}) async {
    final where = status != null ? 'status = ?' : null;
    final whereArgs = status != null ? [status] : null;
    final maps = await db.query(
      'weekly_plans',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => WeeklyPlan.fromMap(m)).toList();
  }

  Future<WeeklyPlan?> getActivePlan() async {
    final maps = await db.query(
      'weekly_plans',
      where: 'status = ?',
      whereArgs: ['active'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WeeklyPlan.fromMap(maps.first);
  }

  Future<void> updatePlanStatus(int planId, String status) async {
    await db.update(
      'weekly_plans',
      {'status': status},
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  Future<void> deletePlansBefore(int timestamp) async {
    await db.transaction((txn) async {
      final plans = await txn.query(
        'weekly_plans',
        where: 'created_at < ?',
        whereArgs: [timestamp],
      );
      for (final plan in plans) {
        await txn.delete(
          'recipes',
          where: 'plan_id = ?',
          whereArgs: [plan['id']],
        );
        await txn.delete(
          'shopping_items',
          where: 'plan_id = ?',
          whereArgs: [plan['id']],
        );
      }
      await txn.delete(
        'weekly_plans',
        where: 'created_at < ?',
        whereArgs: [timestamp],
      );
      await txn.delete(
        'cooking_records',
        where: 'record_date < ?',
        whereArgs: [timestamp],
      );
    });
  }

  // === Cooking Records（完成烹饪记录，用于每周卡路里统计） ===

  /// 保存(按 record_date 幂等覆盖)一条烹饪记录
  Future<void> saveCookingRecord(CookingRecord record) async {
    await db.insert(
      'cooking_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 按日期升序返回所有烹饪记录
  Future<List<CookingRecord>> getCookingRecords() async {
    final maps = await db.query('cooking_records', orderBy: 'record_date ASC');
    return maps.map((m) => CookingRecord.fromMap(m)).toList();
  }

  /// 按「周一起点」分组,返回每周累积卡路里(升序)
  Future<List<({int weekStart, double total})>> getWeeklyCalories() async {
    final rows = await db.rawQuery(
      'SELECT week_start, SUM(total_calories) AS total '
      'FROM cooking_records GROUP BY week_start ORDER BY week_start ASC',
    );
    return rows
        .map(
          (r) => (
            weekStart: r['week_start'] as int,
            total: (r['total'] as num).toDouble(),
          ),
        )
        .toList();
  }

  /// 最近一周(最大的 week_start 那一周)烹饪记录里的菜名集合，供 AI 避免重复。
  Future<List<String>> getLastWeekDishNames() async {
    final records = await getCookingRecords();
    if (records.isEmpty) return const [];
    final lastWeekStart = records.last.weekStart;
    final names = <String>{};
    for (final r in records.where((r) => r.weekStart == lastWeekStart)) {
      for (final item in r.recipeItems) {
        if (item.name.trim().isNotEmpty) names.add(item.name.trim());
      }
    }
    return names.toList();
  }

  /// 清空用户生成的数据（语言切换时调用）。
  /// 保留 user_profile / ai_config / 厨具(tool)；删除 菜谱、采购、每周计划、冰箱食材、调味料(seasoning)。
  /// 因 sqflite 默认不启用外键级联，须手动先删子表再删父表。
  Future<void> clearUserGeneratedData() async {
    await db.transaction((txn) async {
      await txn.delete('shopping_items');
      await txn.delete('recipes');
      await txn.delete('weekly_plans');
      await txn.delete('ingredients');
      await txn.delete(
        'kitchen_items',
        where: 'type = ?',
        whereArgs: ['seasoning'],
      );
    });
  }

  // === Recipes ===
  Future<int> addRecipe(Recipe recipe) async {
    return await db.insert('recipes', recipe.toMap());
  }

  Future<void> addRecipes(List<Recipe> recipes) async {
    final batch = db.batch();
    for (final r in recipes) {
      batch.insert('recipes', r.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Recipe>> getRecipesByPlan(int planId) async {
    final maps = await db.query(
      'recipes',
      where: 'plan_id = ?',
      whereArgs: [planId],
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<void> deleteRecipesByPlanAndDayRange(int planId, int startDay) async {
    await db.delete(
      'recipes',
      where: 'plan_id = ? AND day_index >= ?',
      whereArgs: [planId, startDay],
    );
  }

  Future<void> deleteShoppingItemsByPlan(int planId) async {
    await db.delete(
      'shopping_items',
      where: 'plan_id = ?',
      whereArgs: [planId],
    );
  }

  Future<List<Recipe>> getRecipesByPlanAndDay(int planId, int dayIndex) async {
    final maps = await db.query(
      'recipes',
      where: 'plan_id = ? AND day_index = ?',
      whereArgs: [planId, dayIndex],
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final maps = await db.query(
      'recipes',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<void> toggleFavorite(int recipeId, bool isFavorite) async {
    await db.update(
      'recipes',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<List<Recipe>> getRecipesInDateRange(int startTs, int endTs) async {
    final maps = await db.rawQuery(
      '''
      SELECT r.* FROM recipes r
      INNER JOIN weekly_plans p ON r.plan_id = p.id
      WHERE p.created_at >= ? AND p.created_at < ?
    ''',
      [startTs, endTs],
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  // === Shopping Items ===
  Future<int> addShoppingItem(ShoppingItem item) async {
    return await db.insert('shopping_items', item.toMap());
  }

  Future<void> addShoppingItems(List<ShoppingItem> items) async {
    final batch = db.batch();
    for (final item in items) {
      batch.insert('shopping_items', item.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<ShoppingItem>> getShoppingItems(int planId) async {
    final maps = await db.query(
      'shopping_items',
      where: 'plan_id = ?',
      whereArgs: [planId],
    );
    return maps.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  Future<List<ShoppingItem>> getUnpurchasedItems(int planId) async {
    final maps = await db.query(
      'shopping_items',
      where: 'plan_id = ? AND purchased = ?',
      whereArgs: [planId, 0],
    );
    return maps.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  Future<void> deleteShoppingItemsByNames(
    int planId,
    List<String> names,
  ) async {
    for (final name in names) {
      await db.delete(
        'shopping_items',
        where: 'plan_id = ? AND name = ?',
        whereArgs: [planId, name],
      );
    }
  }

  /// 批量确认购买：单事务内将采购项移入冰箱并删除采购条目
  /// - 同名已存在：amount>0 时累加存量（单位取 item.unit）；amount<=0（适量）不累加，保持原行
  /// - 不存在：插入 {name, amount, unit}
  Future<void> batchMarkPurchased(
    List<({int itemId, String name, double amount, String unit})> items,
  ) async {
    if (items.isEmpty) return;
    await db.transaction((txn) async {
      for (final item in items) {
        final existing = await txn.query(
          'ingredients',
          where: 'name = ?',
          whereArgs: [item.name],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          if (item.amount > 0) {
            final cur = (existing.first['amount'] as num?)?.toDouble() ?? 0;
            await txn.update(
              'ingredients',
              {
                'amount': cur + item.amount,
                'unit': item.unit,
                'updated_at': DateTime.now().millisecondsSinceEpoch,
              },
              where: 'name = ?',
              whereArgs: [item.name],
            );
          }
          // amount<=0（适量）：不累加，保持原行
        } else {
          await txn.insert('ingredients', {
            'name': item.name,
            'amount': item.amount,
            'unit': item.unit,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
        await txn.delete(
          'shopping_items',
          where: 'id = ?',
          whereArgs: [item.itemId],
        );
      }
    });
  }

  // 新增：完成烹饪扣除——冰箱优先，不足从采购扣，归零删除（仅食材）
  Future<void> consumeForCooking(
    int planId,
    List<({String name, double amount, String unit})> needs,
  ) async {
    await db.transaction((txn) async {
      for (final need in needs) {
        await _consumeOne(txn, planId, need.name, need.amount);
      }
    });
  }

  Future<void> _consumeOne(
    DatabaseExecutor txn,
    int planId,
    String name,
    double needAmount,
  ) async {
    final fridgeRows = await txn.query(
      'ingredients',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    final fridge = fridgeRows.isNotEmpty ? fridgeRows.first : null;
    final fridgeAmount = (fridge?['amount'] as num?)?.toDouble() ?? 0;

    if (needAmount <= 0) {
      // 适量：用完当前可用整条
      if (fridge != null && fridgeAmount > 0) {
        await txn.delete(
          'ingredients',
          where: 'id = ?',
          whereArgs: [fridge['id']],
        );
      } else {
        await _consumeShopAll(txn, planId, name);
      }
      return;
    }

    if (fridge != null && fridgeAmount > 0) {
      if (fridgeAmount >= needAmount) {
        final remaining = fridgeAmount - needAmount;
        if (remaining <= 0) {
          await txn.delete(
            'ingredients',
            where: 'id = ?',
            whereArgs: [fridge['id']],
          );
        } else {
          await txn.update(
            'ingredients',
            {
              'amount': remaining,
              'unit': (fridge['unit'] as String? ?? ''),
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: [fridge['id']],
          );
        }
      } else {
        await txn.delete(
          'ingredients',
          where: 'id = ?',
          whereArgs: [fridge['id']],
        );
        await _consumeShop(txn, planId, name, needAmount - fridgeAmount);
      }
    } else {
      await _consumeShop(txn, planId, name, needAmount);
    }
  }

  Future<void> _consumeShop(
    DatabaseExecutor txn,
    int planId,
    String name,
    double amount,
  ) async {
    final rows = await txn.query(
      'shopping_items',
      where: 'plan_id = ? AND name = ?',
      whereArgs: [planId, name],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final item = rows.first;
    final itemAmount = (item['amount'] as num?)?.toDouble() ?? 0;
    final itemUnit = item['unit'] as String? ?? '';
    if (itemAmount <= 0) {
      // 适量：用完当前整条
      await txn.delete(
        'shopping_items',
        where: 'id = ?',
        whereArgs: [item['id']],
      );
      return;
    }
    final remaining = itemAmount - amount;
    if (remaining <= 0) {
      await txn.delete(
        'shopping_items',
        where: 'id = ?',
        whereArgs: [item['id']],
      );
    } else {
      await txn.update(
        'shopping_items',
        {'amount': remaining, 'unit': itemUnit},
        where: 'id = ?',
        whereArgs: [item['id']],
      );
    }
  }

  Future<void> _consumeShopAll(
    DatabaseExecutor txn,
    int planId,
    String name,
  ) async {
    await txn.delete(
      'shopping_items',
      where: 'plan_id = ? AND name = ?',
      whereArgs: [planId, name],
    );
  }

  // === AI Config ===
  Future<Map<String, String>> getAIConfig() async {
    final maps = await db.query('ai_config', limit: 1);
    if (maps.isEmpty) {
      return {'api_key': '', 'model': 'deepseek-v4-flash', 'base_url': ''};
    }
    return {
      'api_key': maps.first['api_key'] as String? ?? '',
      'model': maps.first['model'] as String? ?? 'deepseek-v4-flash',
      'base_url': maps.first['base_url'] as String? ?? '',
    };
  }

  Future<void> saveAIConfig(String apiKey, String model, String baseUrl) async {
    final existing = await db.query('ai_config', limit: 1);
    if (existing.isNotEmpty) {
      await db.update(
        'ai_config',
        {'api_key': apiKey, 'model': model, 'base_url': baseUrl},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('ai_config', {
        'api_key': apiKey,
        'model': model,
        'base_url': baseUrl,
      });
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
