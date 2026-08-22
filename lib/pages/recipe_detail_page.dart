// lib/pages/recipe_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/meal_plan_provider.dart';
import '../theme.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealPlanProvider>();

    // 解析食材列表
    List<String> ingredients = [];
    if (recipe.ingredientList.isNotEmpty) {
      try {
        final list = jsonDecode(recipe.ingredientList) as List;
        ingredients = list.cast<String>();
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        // 标题完整显示，不截断
        title: Text(recipe.name, style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.visible),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite ? Colors.red : null,
            ),
            onPressed: () => provider.toggleFavorite(recipe.id!, !recipe.isFavorite),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 菜品名称（完整显示）
            Text(
              recipe.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 餐次标签 + 卡路里
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(recipe.mealType, style: const TextStyle(fontSize: 13)),
                  avatar: Icon(
                    recipe.mealType == '早餐' ? Icons.wb_sunny : Icons.restaurant,
                    size: 16,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                if (recipe.calories != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, size: 18, color: kSeedBlue),
                      const SizedBox(width: 4),
                      Text('${recipe.calories!.toInt()} kcal',
                          style: const TextStyle(fontSize: 15, color: kSeedBlue)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 烹饪步骤
            const Text('烹饪步骤', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recipe.description.isNotEmpty ? recipe.description : '暂无详细步骤',
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),

            // 食材清单
            const Text('食材清单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (ingredients.isEmpty)
              const Text('暂无食材信息', style: TextStyle(color: Colors.grey))
            else
              ...ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: kSeedBlue),
                        const SizedBox(width: 10),
                        Text(ingredient, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}