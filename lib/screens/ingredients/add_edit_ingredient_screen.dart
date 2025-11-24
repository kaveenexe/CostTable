import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ingredient.dart';
import '../../providers/ingredients_provider.dart';

class AddEditIngredientScreen extends StatefulWidget {
  final Ingredient? ingredient;

  const AddEditIngredientScreen({super.key, this.ingredient});

  @override
  State<AddEditIngredientScreen> createState() =>
      _AddEditIngredientScreenState();
}

class _AddEditIngredientScreenState extends State<AddEditIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _unitController;
  late TextEditingController _priceController;
  late TextEditingController _supplierController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient?.name);
    _unitController = TextEditingController(text: widget.ingredient?.baseUnit);
    _priceController =
        TextEditingController(text: widget.ingredient?.currentPrice.toString());
    _supplierController =
        TextEditingController(text: widget.ingredient?.supplier);
    _notesController = TextEditingController(text: widget.ingredient?.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveIngredient() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final unit = _unitController.text;
      final price = double.parse(_priceController.text);
      final supplier = _supplierController.text;
      final notes = _notesController.text;
      final now = DateTime.now().millisecondsSinceEpoch;

      final ingredient = Ingredient(
        id: widget.ingredient?.id,
        name: name,
        baseUnit: unit,
        currentPrice: price,
        lastUpdated: now,
        supplier: supplier.isEmpty ? null : supplier,
        notes: notes.isEmpty ? null : notes,
        createdAt: widget.ingredient?.createdAt ?? now,
      );

      final provider = Provider.of<IngredientsProvider>(context, listen: false);
      if (widget.ingredient == null) {
        provider.addIngredient(ingredient);
      } else {
        provider.updateIngredient(ingredient);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ingredient == null ? 'Add Ingredient' : 'Edit Ingredient'),
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
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Base Unit (e.g., kg, L, piece)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per Unit'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'Supplier (Optional)'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveIngredient,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
