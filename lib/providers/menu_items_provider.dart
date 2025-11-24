import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/recipe_ingredient.dart';
import '../database/database_helper.dart';

class MenuItemsProvider with ChangeNotifier {
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  Future<void> loadMenuItems() async {
    _isLoading = true;
    notifyListeners();

    _menuItems = await DatabaseHelper.instance.readAllMenuItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addMenuItem(MenuItem menuItem) async {
    final id = await DatabaseHelper.instance.createMenuItem(menuItem);
    await loadMenuItems();
    return id;
  }

  Future<void> updateMenuItem(MenuItem menuItem) async {
    await DatabaseHelper.instance.updateMenuItem(menuItem);
    await loadMenuItems();
  }

  Future<void> deleteMenuItem(int id) async {
    await DatabaseHelper.instance.deleteMenuItem(id);
    await loadMenuItems();
  }

  Future<List<RecipeIngredient>> getRecipeIngredients(int menuItemId) async {
    return await DatabaseHelper.instance.getRecipeIngredients(menuItemId);
  }

  Future<void> saveRecipeIngredients(
      int menuItemId, List<RecipeIngredient> ingredients) async {
    // Clear existing ingredients for this menu item
    await DatabaseHelper.instance.clearRecipeIngredients(menuItemId);
    
    // Add new ingredients
    for (var ingredient in ingredients) {
      // Ensure the ingredient has the correct menu_item_id
      final newIngredient = RecipeIngredient(
        menuItemId: menuItemId,
        ingredientId: ingredient.ingredientId,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        notes: ingredient.notes,
      );
      await DatabaseHelper.instance.addRecipeIngredient(newIngredient);
    }
    notifyListeners();
  }
}
