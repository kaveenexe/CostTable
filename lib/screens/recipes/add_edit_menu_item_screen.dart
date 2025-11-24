import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/recipe_ingredient.dart';
import '../../models/ingredient.dart';
import '../../providers/menu_items_provider.dart';
import '../../providers/ingredients_provider.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItem? menuItem;

  const AddEditMenuItemScreen({super.key, this.menuItem});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;
  late TextEditingController _sellingPriceController;
  
  List<RecipeIngredient> _recipeIngredients = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem?.name);
    _descriptionController =
        TextEditingController(text: widget.menuItem?.description);
    _servingsController = TextEditingController(
        text: widget.menuItem?.servingsPerRecipe.toString() ?? '1');
    _sellingPriceController = TextEditingController(
        text: widget.menuItem?.baseSellingPrice?.toString());

    if (widget.menuItem != null) {
      _loadRecipeIngredients();
    }
    
    // Load ingredients for the dropdown
    Future.microtask(() =>
        Provider.of<IngredientsProvider>(context, listen: false).loadIngredients());
  }

  Future<void> _loadRecipeIngredients() async {
    final ingredients = await Provider.of<MenuItemsProvider>(context, listen: false)
        .getRecipeIngredients(widget.menuItem!.id!);
    setState(() {
      _recipeIngredients = ingredients;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  void _saveMenuItem() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final description = _descriptionController.text;
      final servings = int.parse(_servingsController.text);
      final sellingPrice = double.tryParse(_sellingPriceController.text);
      final now = DateTime.now().millisecondsSinceEpoch;

      final menuItem = MenuItem(
        id: widget.menuItem?.id,
        name: name,
        description: description.isEmpty ? null : description,
        servingsPerRecipe: servings,
        baseSellingPrice: sellingPrice,
        createdAt: widget.menuItem?.createdAt ?? now,
        updatedAt: now,
      );

      final provider = Provider.of<MenuItemsProvider>(context, listen: false);
      int menuItemId;
      if (widget.menuItem == null) {
        menuItemId = await provider.addMenuItem(menuItem);
      } else {
        await provider.updateMenuItem(menuItem);
        menuItemId = widget.menuItem!.id!;
      }

      await provider.saveRecipeIngredients(menuItemId, _recipeIngredients);

      if (mounted) Navigator.pop(context);
    }
  }

  void _addIngredientDialog() {
    final ingredientsProvider =
        Provider.of<IngredientsProvider>(context, listen: false);
    Ingredient? selectedIngredient;
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Ingredient'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Ingredient>(
                  decoration: const InputDecoration(labelText: 'Ingredient'),
                  items: ingredientsProvider.ingredients.map((ingredient) {
                    return DropdownMenuItem(
                      value: ingredient,
                      child: Text(ingredient.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIngredient = value;
                      unitController.text = value?.baseUnit ?? '';
                    });
                  },
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedIngredient != null &&
                  quantityController.text.isNotEmpty) {
                setState(() {
                  _recipeIngredients.add(RecipeIngredient(
                    menuItemId: 0, // Temporary ID
                    ingredientId: selectedIngredient!.id!,
                    quantity: double.parse(quantityController.text),
                    unit: unitController.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem == null ? 'Add Menu Item' : 'Edit Menu Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Servings per Recipe'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter servings';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(labelText: 'Base Selling Price (Optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Recipe Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recipeIngredients.length,
                itemBuilder: (context, index) {
                  final recipeIngredient = _recipeIngredients[index];
                  final ingredient = Provider.of<IngredientsProvider>(context, listen: false)
                      .ingredients
                      .firstWhere((i) => i.id == recipeIngredient.ingredientId,
                          orElse: () => Ingredient(
                              id: -1,
                              name: 'Unknown',
                              baseUnit: '',
                              currentPrice: 0,
                              lastUpdated: 0,
                              createdAt: 0));
                  
                  return ListTile(
                    title: Text(ingredient.name),
                    subtitle: Text(
                        '${recipeIngredient.quantity} ${recipeIngredient.unit}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _recipeIngredients.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: _addIngredientDialog,
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMenuItem,
                child: const Text('Save Menu Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
