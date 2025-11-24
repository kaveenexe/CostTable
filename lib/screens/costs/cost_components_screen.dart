import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cost_component.dart';
import '../../database/database_helper.dart';

class CostComponentsScreen extends StatefulWidget {
  const CostComponentsScreen({super.key});

  @override
  State<CostComponentsScreen> createState() => _CostComponentsScreenState();
}

class _CostComponentsScreenState extends State<CostComponentsScreen> {
  List<CostComponent> _costComponents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCostComponents();
  }

  Future<void> _loadCostComponents() async {
    setState(() => _isLoading = true);
    final components = await DatabaseHelper.instance.readAllCostComponents();
    setState(() {
      _costComponents = components;
      _isLoading = false;
    });
  }

  Future<void> _addOrEditCostComponent([CostComponent? component]) async {
    final nameController = TextEditingController(text: component?.name);
    final amountController =
        TextEditingController(text: component?.amount.toString());
    String category = component?.category ?? 'DIRECT';
    bool isPercentage = component?.isPercentage == 1;
    bool isActive = component?.isActive == 1;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(component == null ? 'Add Cost Component' : 'Edit Cost Component'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ['DIRECT', 'INDIRECT']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => category = value!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                CheckboxListTile(
                  title: const Text('Is Percentage?'),
                  value: isPercentage,
                  onChanged: (value) => setState(() => isPercentage = value!),
                ),
                CheckboxListTile(
                  title: const Text('Is Active?'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    final newComponent = CostComponent(
                      id: component?.id,
                      name: nameController.text,
                      category: category,
                      amount: double.parse(amountController.text),
                      isPercentage: isPercentage ? 1 : 0,
                      isActive: isActive ? 1 : 0,
                      createdAt: component?.createdAt ??
                          DateTime.now().millisecondsSinceEpoch,
                    );

                    if (component == null) {
                      await DatabaseHelper.instance
                          .createCostComponent(newComponent);
                    } else {
                      await DatabaseHelper.instance
                          .updateCostComponent(newComponent);
                    }
                    _loadCostComponents();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCostComponent(int id) async {
    await DatabaseHelper.instance.deleteCostComponent(id);
    _loadCostComponents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Components'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _costComponents.length,
              itemBuilder: (context, index) {
                final component = _costComponents[index];
                return ListTile(
                  title: Text(component.name),
                  subtitle: Text(
                      '${component.category} | ${component.amount}${component.isPercentage == 1 ? '%' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: component.isActive == 1,
                        onChanged: (value) async {
                          final updatedComponent = CostComponent(
                            id: component.id,
                            name: component.name,
                            category: component.category,
                            amount: component.amount,
                            isPercentage: component.isPercentage,
                            isActive: value ? 1 : 0,
                            appliesTo: component.appliesTo,
                            notes: component.notes,
                            createdAt: component.createdAt,
                          );
                          await DatabaseHelper.instance
                              .updateCostComponent(updatedComponent);
                          _loadCostComponents();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditCostComponent(component),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCostComponent(component.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditCostComponent(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
