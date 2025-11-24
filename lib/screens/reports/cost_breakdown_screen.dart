import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/ingredient.dart';
import '../../models/recipe_ingredient.dart';
import '../../models/cost_component.dart';
import '../../providers/menu_items_provider.dart';
import '../../providers/ingredients_provider.dart';
import '../../services/cost_calculator.dart';
import '../../database/database_helper.dart';

class CostBreakdownScreen extends StatefulWidget {
  final MenuItem menuItem;

  const CostBreakdownScreen({super.key, required this.menuItem});

  @override
  State<CostBreakdownScreen> createState() => _CostBreakdownScreenState();
}

class _CostBreakdownScreenState extends State<CostBreakdownScreen> {
  List<RecipeIngredient> _recipeIngredients = [];
  List<CostComponent> _costComponents = [];
  bool _isLoading = true;
  double _desiredMargin = 60.0;

  double _targetServings = 1.0;
  TextEditingController _servingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final ingredientsProvider = Provider.of<IngredientsProvider>(context, listen: false);
    if (ingredientsProvider.ingredients.isEmpty) {
      await ingredientsProvider.loadIngredients();
    }

    final recipeIngredients = await Provider.of<MenuItemsProvider>(context, listen: false)
        .getRecipeIngredients(widget.menuItem.id!);
    
    final costComponents = await DatabaseHelper.instance.readAllCostComponents();

    setState(() {
      _recipeIngredients = recipeIngredients;
      _costComponents = costComponents;
      _isLoading = false;
      _targetServings = widget.menuItem.servingsPerRecipe.toDouble();
      _servingsController.text = _targetServings.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allIngredients = Provider.of<IngredientsProvider>(context, listen: false).ingredients;

    // Calculations
    final rawFoodCost = CostCalculator.calculateRawFoodCost(
      widget.menuItem,
      _recipeIngredients,
      allIngredients,
    );

    final directCosts = CostCalculator.calculateDirectCosts(
      rawFoodCost,
      _costComponents,
    );

    final indirectCosts = CostCalculator.calculateIndirectCosts(
      rawFoodCost,
      directCosts,
      _costComponents,
    );

    final totalCost = CostCalculator.calculateTotalCost(
      rawFoodCost,
      directCosts,
      indirectCosts,
    );

    final sellingPrice = CostCalculator.calculateSellingPrice(
      totalCost,
      _desiredMargin,
    );

    final profit = sellingPrice - totalCost;
    final contributionMargin = CostCalculator.calculateContributionMargin(
      sellingPrice,
      rawFoodCost,
      directCosts,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL COST PER SERVING',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalCost.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Raw Food', rawFoodCost.toStringAsFixed(2)),
                        _buildSummaryItem('Direct', directCosts.toStringAsFixed(2)),
                        _buildSummaryItem('Indirect', indirectCosts.toStringAsFixed(2)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Pricing Strategy'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Desired Margin', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('${_desiredMargin.round()}%', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                      ],
                    ),
                    Slider(
                      value: _desiredMargin,
                      min: 0,
                      max: 99,
                      divisions: 99,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          _desiredMargin = value;
                        });
                      },
                    ),
                    const Divider(height: 24),
                    _buildPricingRow('Suggested Price', sellingPrice, isBold: true, color: Colors.green[700]),
                    const SizedBox(height: 8),
                    _buildPricingRow('Projected Profit', profit),
                    const SizedBox(height: 8),
                    _buildPricingRow('Contribution Margin', contributionMargin, isPercentage: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Recipe Scaling'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Target Servings:', style: TextStyle(fontSize: 16))),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _servingsController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _targetServings = double.tryParse(value) ?? widget.menuItem.servingsPerRecipe.toDouble();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text('View Scaled Ingredients'),
                      tilePadding: EdgeInsets.zero,
                      children: _recipeIngredients.map((ri) {
                         final ingredient = allIngredients.firstWhere((i) => i.id == ri.ingredientId, orElse: () => Ingredient(id: -1, name: 'Unknown', baseUnit: '', currentPrice: 0, lastUpdated: 0, createdAt: 0));
                         final scaleFactor = _targetServings / widget.menuItem.servingsPerRecipe;
                         final scaledQuantity = ri.quantity * scaleFactor;
                         
                         return ListTile(
                           contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                           title: Text(ingredient.name, style: const TextStyle(fontSize: 14)),
                           trailing: Text(
                             '${scaledQuantity.toStringAsFixed(2)} ${ri.unit}',
                             style: const TextStyle(fontWeight: FontWeight.bold),
                           ),
                         );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Cost Breakdown'),
            _buildBreakdownCard('Direct Costs', _costComponents.where((c) => c.category == 'DIRECT' && c.isActive == 1).toList()),
            const SizedBox(height: 12),
            _buildBreakdownCard('Indirect Costs', _costComponents.where((c) => c.category == 'INDIRECT' && c.isActive == 1).toList()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, double value, {bool isBold = false, Color? color, bool isPercentage = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
        Text(
          isPercentage ? '${value.toStringAsFixed(1)}%' : value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(String title, List<CostComponent> components) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: components.isEmpty 
            ? [const Padding(padding: EdgeInsets.all(16), child: Text('No costs applied'))]
            : components.map((c) => ListTile(
                title: Text(c.name),
                trailing: Text(c.isPercentage == 1 ? '${c.amount}%' : '${c.amount}'),
              )).toList(),
      ),
    );
  }
}
