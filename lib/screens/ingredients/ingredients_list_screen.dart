import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/ingredients_provider.dart';
import '../../models/ingredient.dart';
import 'add_edit_ingredient_screen.dart';

class IngredientsListScreen extends StatefulWidget {
  const IngredientsListScreen({super.key});

  @override
  State<IngredientsListScreen> createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<IngredientsProvider>(context, listen: false).loadIngredients());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<IngredientsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ingredients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.kitchen, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No ingredients yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first ingredient'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = provider.ingredients[index];
              final isOld = DateTime.now().millisecondsSinceEpoch -
                      ingredient.lastUpdated >
                  7 * 24 * 60 * 60 * 1000;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditIngredientScreen(
                          ingredient: ingredient,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.egg_alt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ingredient.currentPrice} / ${ingredient.baseUnit}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOld)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Tooltip(
                              message: 'Price not updated in 7 days',
                              child: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            ),
                          ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditIngredientScreen(),
            ),
          );
        },
        label: const Text('Add Ingredient'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
