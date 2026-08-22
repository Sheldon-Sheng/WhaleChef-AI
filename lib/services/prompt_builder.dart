// lib/services/prompt_builder.dart
import '../models/user_profile.dart';
import '../models/ingredient.dart';
import '../models/kitchen_item.dart';
import '../models/recipe.dart';

class PromptBuilder {
  /// 构建发送给 DeepSeek 的完整 Prompt
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
  }) {
    final buffer = StringBuffer();

    buffer.writeln('你是一位专业的营养师和私人厨师。请根据以下信息为用户规划一周菜谱。');
    buffer.writeln('');

    // 身体数据
    buffer.writeln('## 用户身体数据');
    buffer.writeln('- 年龄：${user.age}');
    buffer.writeln('- 性别：${user.gender}');
    buffer.writeln('- 身高：${user.height}cm');
    buffer.writeln('- 体重：${user.weight}kg');
    if (user.bodyFatRate != null) buffer.writeln('- 体脂率：${user.bodyFatRate}%');
    if (user.healthReportNotes != null && user.healthReportNotes!.isNotEmpty) {
      buffer.writeln('- 体检报告异常项：${user.healthReportNotes}');
    }
    if (user.chronicDiseases != null && user.chronicDiseases!.isNotEmpty) {
      buffer.writeln('- 慢性病：${user.chronicDiseases}');
    }
    buffer.writeln('');

    // 目标数据
    buffer.writeln('## 用户目标');
    buffer.writeln('- 目标体重：${user.targetWeight}kg');
    buffer.writeln('- 目标体脂率：${user.targetBodyFat}%');
    buffer.writeln('');

    // 食物偏好
    buffer.writeln('## 食物偏好');
    buffer.writeln('- 爱吃的食物：${user.preferredFoods}');
    buffer.writeln('- 讨厌的食物：${user.dislikedFoods}');
    buffer.writeln('');

    // 冰箱库存
    buffer.writeln('## 冰箱食材库存');
    if (fridgeItems.isEmpty) {
      buffer.writeln('- 冰箱为空，请在采购清单中列出所需食材');
    } else {
      for (final item in fridgeItems) {
        buffer.writeln('- ${item.name}：${item.quantity}');
      }
    }
    buffer.writeln('');

    // 厨房工具
    buffer.writeln('## 厨房工具');
    for (final tool in tools.where((t) => t.isAvailable)) {
      buffer.writeln('- ${tool.name}');
    }
    buffer.writeln('');

    // 调味料
    buffer.writeln('## 可用调味料');
    for (final s in seasonings.where((s) => s.isAvailable)) {
      buffer.writeln('- ${s.name}');
    }
    buffer.writeln('');

    // 菜谱要求
    buffer.writeln('## 菜谱要求');
    buffer.writeln('- 每餐 $dishesCount 道菜（$meatDishes 荤 $veggieDishes 素）${wantSoup ? '，加汤' : ''}');
    buffer.writeln('- 烹饪时间限制：$cookingTimeMinutes 分钟内完成');
    buffer.writeln('- 菜品风格：$cuisineStyle');

    // 餐次选择
    final List<String> selectedMeals = [];
    if (wantBreakfast) selectedMeals.add('早餐');
    if (wantLunch) selectedMeals.add('午餐');
    if (wantDinner) selectedMeals.add('晚餐');
    if (selectedMeals.length < 3) {
      buffer.writeln('- 只需规划以下餐次：${selectedMeals.join('、')}');
    }
    buffer.writeln('');

    // 历史菜谱
    if (historyRecipes.isNotEmpty) {
      buffer.writeln('## 近期历史菜谱（请参考避免重复，保证营养均衡）');
      for (final r in historyRecipes) {
        buffer.writeln('- ${r.name}（${r.mealType}）');
      }
      buffer.writeln('');
    }

    // 收藏菜谱优先
    if (preferFavorites && favoriteCount > 0) {
      buffer.writeln('## 收藏菜谱优先');
      buffer.writeln('- 请优先从以下收藏菜谱中选择 $favoriteCount 道菜放入计划：');
      if (favoriteRecipes.isEmpty) {
        buffer.writeln('- 用户暂无收藏菜谱');
      } else {
        for (final r in favoriteRecipes) {
          buffer.writeln('- ${r.name}（${r.mealType}）${r.description.isNotEmpty ? '：${r.description}' : ''}');
        }
      }
      buffer.writeln('- 如果收藏菜谱数量不足 $favoriteCount，则由你根据实际情况为剩余空缺规划新菜谱，无需提示用户。');
      buffer.writeln('');
    }

    // 是否重排
    if (startFromDay != null) {
      buffer.writeln('## 说明');
      buffer.writeln('本周已执行到第 $startFromDay 天，请从第 $startFromDay 天开始规划剩余菜谱。');
      buffer.writeln('已执行的天数无需重复规划。');
      buffer.writeln('');
    }

    // 输出格式
    buffer.writeln('## 输出格式要求');
    buffer.writeln('请严格按照以下 JSON 格式输出，不要有任何多余的文字或说明：');
    buffer.writeln('''
{
  "week_plan": {
    "shopping_list": [
      {"name": "食材名称", "quantity": "数量（如 500g、3个）"}
    ],
    "days": [
      {
        "day": 1,
        "meals": [
          {"type": "早餐", "name": "菜名", "description": "简要做法说明", "calories": 300,
           "ingredients": [{"name": "食材1", "quantity": "数量（如 2个、500g）"}],
           "seasonings": ["调味品1", "调味品2"]},
          {"type": "午餐", "name": "菜名", "description": "简要做法说明", "calories": 500,
           "ingredients": [{"name": "食材1", "quantity": "数量（如 2个、500g）"}],
           "seasonings": ["调味品1", "调味品2"]}
        ]
      }
    ]
  }
}
''');

    return buffer.toString();
  }
}