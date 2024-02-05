import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/category.dart';
import 'package:meals/widget/category_grid_item.dart';
import 'package:meals/screen/meals_screen.dart';
import 'package:meals/models/meal.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    super.key,
    required this.onToggleFavorite,
    required this.availableMeals,
  });

  final void Function(Meal meal) onToggleFavorite;
  final List<Meal> availableMeals;

  @override
  Widget build(BuildContext context) {

    void _selectedCategory(BuildContext context, Category category) {
      final filteredMeals = availableMeals
          .where((meal) => meal.categories.contains(category.id))
          .toList();

          
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((ctx) => MealsScreen(
                  meals: filteredMeals,
                  title: category.title,
                  onToggleFavorite: onToggleFavorite,
                )),
          ));
    }

    return GridView(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      children: [
        for (final category in availableCategories)
          CategoryGridItem(
            category: category,
            onSelectCategory: () {
              _selectedCategory(context, category);
            },
          )
      ],
    );
  }
}
