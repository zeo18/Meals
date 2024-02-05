import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/screen/categories_screen.dart';
import 'package:meals/screen/filters_Screen.dart';
import 'package:meals/screen/meals_screen.dart';
import 'package:meals/widget/main_drawer.dart';
import 'package:meals/provider/meals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kInitialFilters = {
  Filters.glutenFree: false,
  Filters.lactoseFree: false,
  Filters.vegetarian: false,
  Filters.vegan: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;

  final List<Meal> _favoriteMeals = [];

  Map<Filters, bool> _selectedFilters = kInitialFilters;

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _toggleMealFavoriteStatus(Meal meal) {
    final isExisting = _favoriteMeals.contains(meal);

    if (isExisting) {
      setState(() {
        _favoriteMeals.remove(meal);
        _showInfoMessage('Meal is no longer Favortie!');
      });
    } else {
      setState(() {
        _favoriteMeals.add(meal);
        _showInfoMessage('Marked as a Favorite');
      });
    }
  }

  void selectedPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    print(_selectedPageIndex);
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      final result = await Navigator.push<Map<Filters, bool>>(
        context,
        MaterialPageRoute(
          builder: (ctx) => FiltersScreen(currentFilters: _selectedFilters),
        ),
      );
      _selectedFilters = result ?? kInitialFilters;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final availableMeals = meals.where(
      (meal) {
        if (_selectedFilters[Filters.glutenFree]! && !meal.isGlutenFree) {
          return false;
        }
        if (_selectedFilters[Filters.lactoseFree]! && !meal.isLactoseFree) {
          return false;
        }
        if (_selectedFilters[Filters.vegetarian]! && !meal.isVegetarian) {
          return false;
        }
        if (_selectedFilters[Filters.vegan]! && !meal.isVegan) {
          return false;
        }
        return true;
      },
    ).toList();

    Widget activePage = CategoriesScreen(
      onToggleFavorite: _toggleMealFavoriteStatus,
      availableMeals: availableMeals,
    );
    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
        meals: _favoriteMeals,
        onToggleFavorite: _toggleMealFavoriteStatus,
      );
      activePageTitle = 'Your Favorities';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activePageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: MainDrawer(onSelectScreen: _setScreen),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectedPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.set_meal), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorities'),
        ],
      ),
    );
  }
}
