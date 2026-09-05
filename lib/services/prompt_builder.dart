// lib/services/prompt_builder.dart
import '../models/user_profile.dart';
import '../models/ingredient.dart';
import '../models/kitchen_item.dart';
import '../models/recipe.dart';

class PromptBuilder {
  /// 构建发送给 DeepSeek 的完整 Prompt。
  /// [isEnglish] 为 true 时生成英文 Prompt，并要求 AI 用英文回复（英文菜名/食材名/单位/餐次）。
  static String buildPrompt({
    required UserProfile user,
    required List<Ingredient> fridgeItems,
    required List<KitchenItem> tools,
    required List<KitchenItem> seasonings,
    required List<Recipe> historyRecipes,
    List<Recipe> favoriteRecipes = const [],
    int dishesCount = 3,
    int meatDishes = 1,
    int veggieDishes = 2,
    bool wantSoup = true,
    int cookingTimeMinutes = 30,
    String cuisineStyle = '中餐',
    int? startFromDay,
    bool wantBreakfast = true,
    bool wantLunch = true,
    bool wantDinner = true,
    bool preferFavorites = false,
    int favoriteCount = 0,
    bool isEnglish = false,
    List<String> avoidDishNames = const [],
  }) {
    if (isEnglish) {
      return _buildPromptEn(
        user: user,
        fridgeItems: fridgeItems,
        tools: tools,
        seasonings: seasonings,
        historyRecipes: historyRecipes,
        favoriteRecipes: favoriteRecipes,
        dishesCount: dishesCount,
        meatDishes: meatDishes,
        veggieDishes: veggieDishes,
        wantSoup: wantSoup,
        cookingTimeMinutes: cookingTimeMinutes,
        cuisineStyle: cuisineStyle,
        startFromDay: startFromDay,
        wantBreakfast: wantBreakfast,
        wantLunch: wantLunch,
        wantDinner: wantDinner,
        preferFavorites: preferFavorites,
        favoriteCount: favoriteCount,
        avoidDishNames: avoidDishNames,
      );
    }
    return _buildPromptZh(
      user: user,
      fridgeItems: fridgeItems,
      tools: tools,
      seasonings: seasonings,
      historyRecipes: historyRecipes,
      favoriteRecipes: favoriteRecipes,
      dishesCount: dishesCount,
      meatDishes: meatDishes,
      veggieDishes: veggieDishes,
      wantSoup: wantSoup,
      cookingTimeMinutes: cookingTimeMinutes,
      cuisineStyle: cuisineStyle,
      startFromDay: startFromDay,
      wantBreakfast: wantBreakfast,
      wantLunch: wantLunch,
      wantDinner: wantDinner,
      preferFavorites: preferFavorites,
      favoriteCount: favoriteCount,
      avoidDishNames: avoidDishNames,
    );
  }

  // ---------- 中文版（行为保持不变） ----------
  static String _buildPromptZh({
    required UserProfile user,
    required List<Ingredient> fridgeItems,
    required List<KitchenItem> tools,
    required List<KitchenItem> seasonings,
    required List<Recipe> historyRecipes,
    List<Recipe> favoriteRecipes = const [],
    int dishesCount = 3,
    int meatDishes = 1,
    int veggieDishes = 2,
    bool wantSoup = true,
    int cookingTimeMinutes = 30,
    String cuisineStyle = '中餐',
    int? startFromDay,
    bool wantBreakfast = true,
    bool wantLunch = true,
    bool wantDinner = true,
    bool preferFavorites = false,
    int favoriteCount = 0,
    List<String> avoidDishNames = const [],
  }) {
    final buffer = StringBuffer();

    buffer.writeln('你是一位专业的营养师和私人厨师。请根据以下信息为用户规划一周菜谱。');
    buffer.writeln('');

    buffer.writeln('## 用户身体数据');
    buffer.writeln('- 年龄：${user.age}');
    buffer.writeln('- 性别：${user.gender}');
    buffer.writeln('- 身高：${user.height}cm');
    buffer.writeln('- 体重：${user.weight}kg');
    if (user.bodyFatRate != null) buffer.writeln('- 体脂率：${user.bodyFatRate}%');
    if (user.healthReportNotes != null && user.healthReportNotes!.isNotEmpty) {
      buffer.writeln('- 体检报告异常项：${user.healthReportNotes}');
    }
    buffer.writeln('');

    buffer.writeln('## 用户目标');
    buffer.writeln('- 目标体重：${user.targetWeight}kg');
    buffer.writeln('- 目标体脂率：${user.targetBodyFat}%');
    buffer.writeln('');

    buffer.writeln('## 食物偏好');
    final liked = user.preferredFoods.trim();
    final disliked = user.dislikedFoods.trim();
    if (liked.isEmpty && disliked.isEmpty) {
      buffer.writeln('- 食物偏好：无食物偏好');
    } else {
      buffer.writeln('- 爱吃的食物：${liked.isEmpty ? '（未填写）' : liked}');
      buffer.writeln('- 讨厌的食物：${disliked.isEmpty ? '（未填写）' : disliked}');
    }
    buffer.writeln('');

    buffer.writeln('## 健康与过敏限制（请重点关注并严格审查）');
    final cd = user.chronicDiseases ?? '';
    final ag = user.allergens.trim();
    if (cd.isEmpty && ag.isEmpty) {
      buffer.writeln('- 无已知慢性病或食物过敏，无需特殊忌口。');
    } else {
      buffer.writeln(
        '- 慢性病：${cd.isEmpty ? '无' : cd}。必须避免该慢性病需忌口的食物，菜谱中不得包含相关食材。',
      );
      buffer.writeln(
        '- 过敏的食物：${ag.isEmpty ? '无' : ag}。必须避免需忌口的过敏性食物，菜谱中不得包含相关食材。',
      );
    }
    buffer.writeln('');

    buffer.writeln('## 冰箱食材库存');
    if (fridgeItems.isEmpty) {
      buffer.writeln('- 冰箱为空，请在各餐的 ingredients 中列出所需食材数量');
    } else {
      for (final item in fridgeItems) {
        buffer.writeln('- ${item.name}：${item.quantity}');
      }
    }
    buffer.writeln('');

    buffer.writeln('## 厨房工具');
    for (final tool in tools.where((t) => t.isAvailable)) {
      buffer.writeln('- ${tool.name}');
    }
    buffer.writeln('');

    buffer.writeln('## 可用调味料');
    for (final s in seasonings.where((s) => s.isAvailable)) {
      buffer.writeln('- ${s.name}');
    }
    buffer.writeln('');

    buffer.writeln('## 菜谱要求');
    buffer.writeln(
      '- 每餐共 $dishesCount 道菜，其中荤菜 $meatDishes 道、素菜 $veggieDishes 道${wantSoup ? '，加汤' : ''}',
    );
    buffer.writeln('- 烹饪时间限制：$cookingTimeMinutes 分钟内完成');
    buffer.writeln('- 菜品风格：$cuisineStyle');
    buffer.writeln('- 所有菜品必须能用上面「厨房工具」中列出的厨具完成烹饪；若某道菜需要未列出的厨具，请换用其它合适的菜。');
    buffer.writeln('- 同一种「爱吃的食物」在一周菜谱中出现次数不超过 2 次。');

    final List<String> selectedMeals = [];
    if (wantBreakfast) selectedMeals.add('早餐');
    if (wantLunch) selectedMeals.add('午餐');
    if (wantDinner) selectedMeals.add('晚餐');
    if (selectedMeals.length < 3) {
      buffer.writeln('- 只需规划以下餐次：${selectedMeals.join('、')}');
    }
    buffer.writeln('');

    if (historyRecipes.isNotEmpty) {
      buffer.writeln('## 近期历史菜谱（请参考避免重复，保证营养均衡）');
      for (final r in historyRecipes) {
        buffer.writeln('- ${r.name}（${r.mealType}）');
      }
      buffer.writeln('');
    }

    if (preferFavorites && favoriteCount > 0) {
      buffer.writeln('## 收藏菜谱优先');
      buffer.writeln('- 请优先从以下收藏菜谱中选择 $favoriteCount 道菜放入计划：');
      if (favoriteRecipes.isEmpty) {
        buffer.writeln('- 用户暂无收藏菜谱');
      } else {
        for (final r in favoriteRecipes) {
          buffer.writeln(
            '- ${r.name}（${r.mealType}）${r.description.isNotEmpty ? '：${r.description}' : ''}',
          );
        }
      }
      buffer.writeln('- 如果收藏菜谱数量不足 $favoriteCount，则由你根据实际情况为剩余空缺规划新菜谱，无需提示用户。');
      buffer.writeln('');
    }

    if (startFromDay != null) {
      buffer.writeln('## 说明');
      buffer.writeln('本周已执行到第 $startFromDay 天，请从第 $startFromDay 天开始规划剩余菜谱。');
      buffer.writeln('已执行的天数无需重复规划。');
      buffer.writeln('');
    }

    if (avoidDishNames.isNotEmpty) {
      buffer.writeln('## 上一周已做过的菜（必须避免重复）');
      buffer.writeln('- 以下菜谱在上周已经做过，本周不得出现完全相同的菜：${avoidDishNames.join('、')}');
      buffer.writeln('');
    }

    buffer.writeln('## 输出格式要求');
    buffer.writeln('请严格按照以下 JSON 格式输出，不要有任何多余的文字或说明：');
    buffer.writeln('''
{
  "week_plan": {
    "days": [
      {
        "day": 1,
        "meals": [
          {"type": "早餐", "name": "菜名", "description": "简要做法说明", "calories": 300,
           "ingredients": [{"name": "番茄", "amount": 2, "unit": "个"}, {"name": "盐", "amount": null, "unit": "适量"}],
           "seasonings": ["调味品1", "调味品2"]},
          {"type": "午餐", "name": "菜名", "description": "简要做法说明", "calories": 500,
           "ingredients": [{"name": "食材1", "amount": 200, "unit": "g"}],
           "seasonings": ["调味品1", "调味品2"]}
        ]
      }
    ]
  }
}''');
    buffer.writeln(
      '"amount" 为所需数量数值（无数值则为 null），"unit" 为单位（如 个、g、ml），不要把单位写进 amount。',
    );

    return buffer.toString();
  }

  // ---------- 英文版 ----------
  static String _buildPromptEn({
    required UserProfile user,
    required List<Ingredient> fridgeItems,
    required List<KitchenItem> tools,
    required List<KitchenItem> seasonings,
    required List<Recipe> historyRecipes,
    List<Recipe> favoriteRecipes = const [],
    int dishesCount = 3,
    int meatDishes = 1,
    int veggieDishes = 2,
    bool wantSoup = true,
    int cookingTimeMinutes = 30,
    String cuisineStyle = 'Western',
    int? startFromDay,
    bool wantBreakfast = true,
    bool wantLunch = true,
    bool wantDinner = true,
    bool preferFavorites = false,
    int favoriteCount = 0,
    List<String> avoidDishNames = const [],
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are a professional nutritionist and personal chef. Plan a week of meals for the user based on the information below.',
    );
    buffer.writeln('');

    buffer.writeln('## User Body Data');
    buffer.writeln('- Age: ${user.age}');
    buffer.writeln('- Gender: ${user.gender}');
    buffer.writeln('- Height: ${user.height}cm');
    buffer.writeln('- Weight: ${user.weight}kg');
    if (user.bodyFatRate != null) {
      buffer.writeln('- Body fat: ${user.bodyFatRate}%');
    }
    if (user.healthReportNotes != null && user.healthReportNotes!.isNotEmpty) {
      buffer.writeln('- Health report issues: ${user.healthReportNotes}');
    }
    buffer.writeln('');

    buffer.writeln('## Goals');
    buffer.writeln('- Target weight: ${user.targetWeight}kg');
    buffer.writeln('- Target body fat: ${user.targetBodyFat}%');
    buffer.writeln('');

    buffer.writeln('## Food Preferences');
    final liked = user.preferredFoods.trim();
    final disliked = user.dislikedFoods.trim();
    if (liked.isEmpty && disliked.isEmpty) {
      buffer.writeln('- Food preferences: None');
    } else {
      buffer.writeln(
        '- Liked foods: ${liked.isEmpty ? '(not provided)' : liked}',
      );
      buffer.writeln(
        '- Disliked foods: ${disliked.isEmpty ? '(not provided)' : disliked}',
      );
    }
    buffer.writeln('');

    buffer.writeln('## Health & Allergy Restrictions (review strictly)');
    final cd = user.chronicDiseases ?? '';
    final ag = user.allergens.trim();
    if (cd.isEmpty && ag.isEmpty) {
      buffer.writeln(
        '- No known chronic conditions or food allergies, no special dietary restrictions.',
      );
    } else {
      buffer.writeln(
        '- Chronic conditions: ${cd.isEmpty ? 'None' : cd}. Must avoid foods contraindicated by these conditions; recipes MUST NOT contain such ingredients.',
      );
      buffer.writeln(
        '- Allergens: ${ag.isEmpty ? 'None' : ag}. Must avoid allergenic foods; recipes MUST NOT contain such ingredients.',
      );
    }
    buffer.writeln('');

    buffer.writeln('## Fridge Inventory');
    if (fridgeItems.isEmpty) {
      buffer.writeln(
        '- The fridge is empty. List the needed ingredients with quantities in each meal\'s ingredients.',
      );
    } else {
      for (final item in fridgeItems) {
        buffer.writeln('- ${item.name}: ${item.quantity}');
      }
    }
    buffer.writeln('');

    buffer.writeln('## Kitchen Tools');
    for (final tool in tools.where((t) => t.isAvailable)) {
      buffer.writeln('- ${tool.name}');
    }
    buffer.writeln('');

    buffer.writeln('## Available Seasonings');
    for (final s in seasonings.where((s) => s.isAvailable)) {
      buffer.writeln('- ${s.name}');
    }
    buffer.writeln('');

    buffer.writeln('## Recipe Requirements');
    buffer.writeln(
      '- $dishesCount dishes per meal: $meatDishes meat dish(es) and $veggieDishes veggie dish(es)${wantSoup ? ', plus soup' : ''}',
    );
    buffer.writeln('- Cooking time within $cookingTimeMinutes minutes');
    buffer.writeln('- Cuisine style: $cuisineStyle');
    buffer.writeln(
      '- Every dish must be cookable with the kitchen tools listed under "Kitchen Tools" above. If a dish needs a tool that is not listed, choose a different suitable dish instead.',
    );
    buffer.writeln(
      "- Any single \"liked food\" should appear no more than twice in the week's menu.",
    );

    final List<String> selectedMeals = [];
    if (wantBreakfast) selectedMeals.add('Breakfast');
    if (wantLunch) selectedMeals.add('Lunch');
    if (wantDinner) selectedMeals.add('Dinner');
    if (selectedMeals.length < 3) {
      buffer.writeln('- Only plan these meals: ${selectedMeals.join(', ')}');
    }
    buffer.writeln('');

    if (historyRecipes.isNotEmpty) {
      buffer.writeln(
        '## Recent Recipes (reference to avoid repetition, keep nutrition balanced)',
      );
      for (final r in historyRecipes) {
        buffer.writeln('- ${r.name} (${r.mealType})');
      }
      buffer.writeln('');
    }

    if (preferFavorites && favoriteCount > 0) {
      buffer.writeln('## Favorite Recipes Priority');
      buffer.writeln(
        '- Please prioritize $favoriteCount dishes from the favorites below:',
      );
      if (favoriteRecipes.isEmpty) {
        buffer.writeln('- User has no favorite recipes yet.');
      } else {
        for (final r in favoriteRecipes) {
          buffer.writeln(
            '- ${r.name} (${r.mealType})${r.description.isNotEmpty ? ': ${r.description}' : ''}',
          );
        }
      }
      buffer.writeln(
        '- If there are fewer than $favoriteCount favorites, fill the remaining slots with new dishes. No need to ask the user.',
      );
      buffer.writeln('');
    }

    if (startFromDay != null) {
      buffer.writeln('## Note');
      buffer.writeln(
        'The week has been executed up to day $startFromDay. Plan from day $startFromDay onward.',
      );
      buffer.writeln('Do not replan the executed days.');
      buffer.writeln('');
    }

    if (avoidDishNames.isNotEmpty) {
      buffer.writeln('## Dishes Made Last Week (must not repeat)');
      buffer.writeln(
        '- Do not include any dish identical to these that were made last week: ${avoidDishNames.join(', ')}',
      );
      buffer.writeln('');
    }

    buffer.writeln('## Output Format');
    buffer.writeln(
      'Output STRICTLY the following JSON. No extra text or explanation:',
    );
    buffer.writeln('''
{
  "week_plan": {
    "days": [
      {
        "day": 1,
        "meals": [
          {"type": "Breakfast", "name": "Dish name", "description": "Brief cooking steps", "calories": 300,
           "ingredients": [{"name": "Tomato", "amount": 2, "unit": "pc"}, {"name": "Salt", "amount": null, "unit": "as needed"}],
           "seasonings": ["Seasoning 1", "Seasoning 2"]},
          {"type": "Lunch", "name": "Dish name", "description": "Brief cooking steps", "calories": 500,
           "ingredients": [{"name": "Ingredient 1", "amount": 200, "unit": "g"}],
           "seasonings": ["Seasoning 1", "Seasoning 2"]}
        ]
      }
    ]
  }
}''');
    buffer.writeln(
      '"amount" is the numeric quantity (null if no number), "unit" is the unit (e.g. pc, g, ml). Never put the unit inside amount.',
    );

    return buffer.toString();
  }
}
