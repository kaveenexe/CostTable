import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../database/database_helper.dart';

class IngredientsProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];
  bool _isLoading = false;

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;

  Future<void> loadIngredients() async {
    _isLoading = true;
    notifyListeners();

    _ingredients = await DatabaseHelper.instance.readAllIngredients();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await DatabaseHelper.instance.createIngredient(ingredient);
    await loadIngredients();
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await DatabaseHelper.instance.updateIngredient(ingredient);
    await loadIngredients();
  }

  Future<void> deleteIngredient(int id) async {
    await DatabaseHelper.instance.deleteIngredient(id);
    await loadIngredients();
  }
}
