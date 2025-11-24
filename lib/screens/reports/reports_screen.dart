import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_items_provider.dart';
import '../../providers/ingredients_provider.dart';
import '../../models/menu_item.dart';
import '../../models/cost_component.dart';
import '../../services/cost_calculator.dart';
import '../../database/database_helper.dart';
import 'cost_breakdown_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<CostComponent> _costComponents = [];
  bool _isLoading = true;
  bool _showInactive = false;
  String _sortBy = 'name'; // name, cost, profit

  @override
  void initState() {
    super.initState();
    _loadData();
    Future.microtask(() {
      Provider.of<MenuItemsProvider>(context, listen: false).loadMenuItems();
      Provider.of<IngredientsProvider>(context, listen: false).loadIngredients();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final components = await DatabaseHelper.instance.readAllCostComponents();
    setState(() {
      _costComponents = components;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showInactive ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showInactive = !_showInactive),
            tooltip: _showInactive ? 'Hide Inactive' : 'Show Inactive',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'cost', child: Text('Sort by Cost')),
              const PopupMenuItem(value: 'profit', child: Text('Sort by Profit')),
            ],
          ),
        ],
      ),
      body: Consumer2<MenuItemsProvider, IngredientsProvider>(
        builder: (context, menuProvider, ingredientsProvider, child) {
          if (menuProvider.isLoading || ingredientsProvider.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var items = menuProvider.menuItems;
          if (!_showInactive) {
            items = items.where((i) => i.isActive == 1).toList();
          }

          if (items.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No data to display',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (_sortBy == 'name') {
            items.sort((a, b) => a.name.compareTo(b.name));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return FutureBuilder(
                future: menuProvider.getRecipeIngredients(item.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink(); // Or loading placeholder
                  }
                  
                  final recipeIngredients = snapshot.data!;
                  final allIngredients = ingredientsProvider.ingredients;

                  final rawFoodCost = CostCalculator.calculateRawFoodCost(
                    item,
                    recipeIngredients,
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

                  final sellingPrice = item.baseSellingPrice ?? 0;
                  final profit = sellingPrice - totalCost;
                  final margin = sellingPrice > 0 
                      ? ((profit / sellingPrice) * 100).toStringAsFixed(1) 
                      : '0.0';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CostBreakdownScreen(
                              menuItem: item,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: double.parse(margin) > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$margin% Margin',
                                    style: TextStyle(
                                      color: double.parse(margin) > 0 ? Colors.green[700] : Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatColumn(
                                    context,
                                    'Total Cost',
                                    totalCost.toStringAsFixed(2),
                                    Icons.money_off,
                                    Colors.red[300]!,
                                  ),
                                ),
                                Container(width: 1, height: 40, color: Colors.grey[300]),
                                Expanded(
                                  child: _buildStatColumn(
                                    context,
                                    'Selling Price',
                                    sellingPrice.toStringAsFixed(2),
                                    Icons.attach_money,
                                    Colors.blue[300]!,
                                  ),
                                ),
                                Container(width: 1, height: 40, color: Colors.grey[300]),
                                Expanded(
                                  child: _buildStatColumn(
                                    context,
                                    'Profit',
                                    profit.toStringAsFixed(2),
                                    Icons.trending_up,
                                    Colors.green[300]!,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
