// lib/data/local_db.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/ingredient.dart';
import '../models/kitchen_item.dart';
import '../models/weekly_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../utils/quantity.dart';

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
      version: 3,
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
        await db.execute('ALTER TABLE ingredients ADD COLUMN amount REAL DEFAULT 0');
      }
      if (!colNames.contains('unit')) {
        await db.execute('ALTER TABLE ingredients ADD COLUMN unit TEXT DEFAULT ""');
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
            await db.update('ingredients', {'amount': amount, 'unit': unit}, where: 'id = ?', whereArgs: [row['id']]);
          } else {
            await db.update('ingredients', {'amount': 0, 'unit': qty}, where: 'id = ?', whereArgs: [row['id']]);
          }
        } else if (curAmount == 0) {
          await db.update('ingredients', {'unit': qty}, where: 'id = ?', whereArgs: [row['id']]);
        }
      }
    }
    if (oldVersion < 3) {
      // v2→v3: recipes 加 seasoning_list 列（仅 schema 演进）
      final cols = await db.rawQuery('PRAGMA table_info(recipes)');
      final colNames = cols.map((c) => c['name']).toSet();
      if (!colNames.contains('seasoning_list')) {
        await db.execute('ALTER TABLE recipes ADD COLUMN seasoning_list TEXT DEFAULT "[]"');
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
        quantity TEXT NOT NULL,
        source TEXT DEFAULT 'plan',
        purchased INTEGER DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES weekly_plans(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE ai_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        api_key TEXT NOT NULL DEFAULT '',
        model TEXT NOT NULL DEFAULT 'deepseek-v4-flash'
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
      await db.update('user_profile', profile.toMap(), where: 'id = ?', whereArgs: [existing.id]);
    } else {
      await db.insert('user_profile', profile.toMap());
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await db.update('user_profile', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
  }

  // === Ingredients ===
  Future<List<Ingredient>> getIngredients() async {
    final maps = await db.query('ingredients', orderBy: 'updated_at DESC');
    return maps.map((m) => Ingredient.fromMap(m)).toList();
  }

  Future<Ingredient?> getIngredientByName(String name) async {
    final maps = await db.query('ingredients', where: 'name = ?', whereArgs: [name], limit: 1);
    if (maps.isEmpty) return null;
    return Ingredient.fromMap(maps.first);
  }

  Future<void> saveIngredient(String name, double amount, String unit) async {
    final existing = await getIngredientByName(name);
    if (existing != null) {
      await db.update('ingredients',
        {'amount': amount, 'unit': unit, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [existing.id],
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
    await db.update('ingredients', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteIngredient(int id) async {
    await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateIngredientQuantity(int id, double amount, String unit) async {
    await db.update('ingredients', {'amount': amount, 'unit': unit, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
  }

  // === Kitchen Items ===
  Future<List<KitchenItem>> getKitchenItems({String? type}) async {
    final where = type != null ? 'type = ?' : null;
    final whereArgs = type != null ? [type] : null;
    final maps = await db.query('kitchen_items', where: where, whereArgs: whereArgs);
    return maps.map((m) => KitchenItem.fromMap(m)).toList();
  }

  Future<int> addKitchenItem(KitchenItem item) async {
    return await db.insert('kitchen_items', item.toMap());
  }

  Future<void> updateKitchenItem(KitchenItem item) async {
    await db.update('kitchen_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
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
    final maps = await db.query('weekly_plans', where: where, whereArgs: whereArgs, orderBy: 'created_at DESC');
    return maps.map((m) => WeeklyPlan.fromMap(m)).toList();
  }

  Future<WeeklyPlan?> getActivePlan() async {
    final maps = await db.query('weekly_plans', where: 'status = ?', whereArgs: ['active'], limit: 1);
    if (maps.isEmpty) return null;
    return WeeklyPlan.fromMap(maps.first);
  }

  Future<void> updatePlanStatus(int planId, String status) async {
    await db.update('weekly_plans', {'status': status}, where: 'id = ?', whereArgs: [planId]);
  }

  Future<void> deletePlansBefore(int timestamp) async {
    await db.transaction((txn) async {
      final plans = await txn.query('weekly_plans', where: 'created_at < ?', whereArgs: [timestamp]);
      for (final plan in plans) {
        await txn.delete('recipes', where: 'plan_id = ?', whereArgs: [plan['id']]);
        await txn.delete('shopping_items', where: 'plan_id = ?', whereArgs: [plan['id']]);
      }
      await txn.delete('weekly_plans', where: 'created_at < ?', whereArgs: [timestamp]);
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
    final maps = await db.query('recipes', where: 'plan_id = ?', whereArgs: [planId]);
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<void> deleteRecipesByPlanAndDayRange(int planId, int startDay) async {
    await db.delete('recipes',
      where: 'plan_id = ? AND day_index >= ?',
      whereArgs: [planId, startDay],
    );
  }

  Future<void> deleteShoppingItemsByPlan(int planId) async {
    await db.delete('shopping_items', where: 'plan_id = ?', whereArgs: [planId]);
  }

  Future<List<Recipe>> getRecipesByPlanAndDay(int planId, int dayIndex) async {
    final maps = await db.query('recipes',
      where: 'plan_id = ? AND day_index = ?',
      whereArgs: [planId, dayIndex],
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final maps = await db.query('recipes', where: 'is_favorite = ?', whereArgs: [1]);
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<void> toggleFavorite(int recipeId, bool isFavorite) async {
    await db.update('recipes', {'is_favorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [recipeId]);
  }

  Future<List<Recipe>> getRecipesInDateRange(int startTs, int endTs) async {
    final maps = await db.rawQuery('''
      SELECT r.* FROM recipes r
      INNER JOIN weekly_plans p ON r.plan_id = p.id
      WHERE p.created_at >= ? AND p.created_at < ?
    ''', [startTs, endTs]);
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
    final maps = await db.query('shopping_items', where: 'plan_id = ?', whereArgs: [planId]);
    return maps.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  Future<List<ShoppingItem>> getUnpurchasedItems(int planId) async {
    final maps = await db.query('shopping_items',
      where: 'plan_id = ? AND purchased = ?',
      whereArgs: [planId, 0],
    );
    return maps.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  Future<void> deleteShoppingItemsByNames(int planId, List<String> names) async {
    for (final name in names) {
      await db.delete('shopping_items',
        where: 'plan_id = ? AND name = ?',
        whereArgs: [planId, name],
      );
    }
  }

  Future<void> batchMarkPurchased(List<({int itemId, String name, String quantity})> items) async {
    await db.transaction((txn) async {
      for (final item in items) {
        final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(item.quantity.trim());
        final amount = (match != null) ? (double.tryParse(match.group(1)!) ?? 0) : 0.0;
        final unit = (match != null) ? (match.group(2)?.trim() ?? '') : item.quantity;

        // 更新冰箱库存
        final existing = await txn.query('ingredients', where: 'name = ?', whereArgs: [item.name], limit: 1);
        if (existing.isNotEmpty) {
          await txn.update('ingredients',
            {'amount': amount, 'unit': unit, 'updated_at': DateTime.now().millisecondsSinceEpoch},
            where: 'name = ?', whereArgs: [item.name],
          );
        } else {
          await txn.insert('ingredients', {
            'name': item.name,
            'amount': amount,
            'unit': unit,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
        // 删除采购项
        await txn.delete('shopping_items', where: 'id = ?', whereArgs: [item.itemId]);
      }
    });
  }

  Future<void> markPurchased(int itemId, String name, String quantity) async {
    await db.transaction((txn) async {
      // 解析数量字符串
      final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(quantity.trim());
      final amount = (match != null) ? (double.tryParse(match.group(1)!) ?? 0) : 0.0;
      final unit = (match != null) ? (match.group(2)?.trim() ?? '') : quantity;

      // 更新冰箱库存
      final existing = await txn.query('ingredients', where: 'name = ?', whereArgs: [name], limit: 1);
      if (existing.isNotEmpty) {
        // 已存在，更新数量
        await txn.update('ingredients',
          {'amount': amount, 'unit': unit, 'updated_at': DateTime.now().millisecondsSinceEpoch},
          where: 'name = ?', whereArgs: [name],
        );
      } else {
        // 不存在，新增
        await txn.insert('ingredients', {
          'name': name,
          'amount': amount,
          'unit': unit,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      // 删除采购项
      await txn.delete('shopping_items', where: 'id = ?', whereArgs: [itemId]);
    });
  }

  // 新增：完成烹饪扣除——冰箱优先，不足从采购扣，归零删除（仅食材）
  Future<void> consumeForCooking(int planId, List<({String name, String quantity})> needs) async {
    await db.transaction((txn) async {
      for (final need in needs) {
        await _consumeOne(txn, planId, need.name, need.quantity);
      }
    });
  }

  Future<void> _consumeOne(DatabaseExecutor txn, int planId, String name, String needQty) async {
    final need = parseQuantity(needQty);
    final fridgeRows = await txn.query('ingredients', where: 'name = ?', whereArgs: [name], limit: 1);
    final fridge = fridgeRows.isNotEmpty ? fridgeRows.first : null;
    final fridgeAmount = (fridge?['amount'] as num?)?.toDouble() ?? 0;

    if (need == null) {
      // 非数值（适量）：用完当前可用整条
      if (fridge != null && fridgeAmount > 0) {
        await txn.delete('ingredients', where: 'id = ?', whereArgs: [fridge['id']]);
      } else {
        await _consumeShopAll(txn, planId, name);
      }
      return;
    }

    if (fridge != null && fridgeAmount > 0) {
      if (fridgeAmount >= need.amount) {
        // 情况一：冰箱足够
        final remaining = fridgeAmount - need.amount;
        if (remaining <= 0) {
          await txn.delete('ingredients', where: 'id = ?', whereArgs: [fridge['id']]);
        } else {
          await txn.update('ingredients',
            {'amount': remaining, 'updated_at': DateTime.now().millisecondsSinceEpoch},
            where: 'id = ?', whereArgs: [fridge['id']],
          );
        }
      } else {
        // 情况三：冰箱部分，不足部分从采购扣
        await txn.delete('ingredients', where: 'id = ?', whereArgs: [fridge['id']]);
        await _consumeShop(txn, planId, name, need.amount - fridgeAmount);
      }
    } else {
      // 情况二：冰箱没有
      await _consumeShop(txn, planId, name, need.amount);
    }
  }

  Future<void> _consumeShop(DatabaseExecutor txn, int planId, String name, double amount) async {
    final rows = await txn.query('shopping_items', where: 'plan_id = ? AND name = ?', whereArgs: [planId, name], limit: 1);
    if (rows.isEmpty) return;
    final item = rows.first;
    final qty = parseQuantity(item['quantity'] as String? ?? '');
    if (qty == null) {
      await txn.delete('shopping_items', where: 'id = ?', whereArgs: [item['id']]);
      return;
    }
    final remaining = qty.amount - amount;
    if (remaining <= 0) {
      await txn.delete('shopping_items', where: 'id = ?', whereArgs: [item['id']]);
    } else {
      await txn.update('shopping_items',
        {'quantity': formatQuantity(remaining, qty.unit)},
        where: 'id = ?', whereArgs: [item['id']],
      );
    }
  }

  Future<void> _consumeShopAll(DatabaseExecutor txn, int planId, String name) async {
    await txn.delete('shopping_items', where: 'plan_id = ? AND name = ?', whereArgs: [planId, name]);
  }

  // === AI Config ===
  Future<Map<String, String>> getAIConfig() async {
    final maps = await db.query('ai_config', limit: 1);
    if (maps.isEmpty) return {'api_key': '', 'model': 'deepseek-v4-flash'};
    return {'api_key': maps.first['api_key'] as String? ?? '', 'model': maps.first['model'] as String? ?? 'deepseek-v4-flash'};
  }

  Future<void> saveAIConfig(String apiKey, String model) async {
    final existing = await db.query('ai_config', limit: 1);
    if (existing.isNotEmpty) {
      await db.update('ai_config', {'api_key': apiKey, 'model': model}, where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      await db.insert('ai_config', {'api_key': apiKey, 'model': model});
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}