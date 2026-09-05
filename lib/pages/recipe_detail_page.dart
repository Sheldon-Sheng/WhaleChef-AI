// lib/pages/recipe_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/meal_plan_provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_language.dart';
import '../utils/meal_type.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<MealPlanProvider>();
    final ingredients = recipe.ingredientItems;
    final seasonings = recipe.seasoningItems;
    final separator = AppLanguage.isEnglish ? ', ' : '、';

    return Scaffold(
      appBar: AppBar(
        // 标题完整显示，不截断
        title: Text(
          recipe.name,
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite ? Colors.red : null,
            ),
            onPressed: () =>
                provider.toggleFavorite(recipe.id!, !recipe.isFavorite),
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
                  label: Text(
                    recipe.mealType,
                    style: const TextStyle(fontSize: 13),
                  ),
                  avatar: Icon(
                    isBreakfastMeal(recipe.mealType)
                        ? Icons.wb_sunny
                        : Icons.restaurant,
                    size: 16,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                if (recipe.calories != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: kSeedBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories!.toInt()} kcal',
                        style: const TextStyle(fontSize: 15, color: kSeedBlue),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 烹饪步骤
            Text(
              l10n.cookingSteps,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // 用主题自适应表面色：浅色模式≈灰白，深色模式自动变暗，避免白底灰字
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recipe.description.isNotEmpty
                    ? recipe.description
                    : l10n.noSteps,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 食材清单
            Text(
              l10n.ingredientList,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (ingredients.isEmpty)
              Text(
                l10n.noIngredients,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ...ingredients.map(
                (ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: kSeedBlue),
                      const SizedBox(width: 8),
                      Text(
                        '${ing.name} ${ing.displayQuantity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            if (seasonings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.seasonings,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                seasonings.join(separator),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
