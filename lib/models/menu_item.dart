class MenuItem {
  final int? id;
  final String name;
  final String? description;
  final int servingsPerRecipe;
  final double? baseSellingPrice;
  final int isActive;
  final int createdAt;
  final int updatedAt;

  MenuItem({
    this.id,
    required this.name,
    this.description,
    this.servingsPerRecipe = 1,
    this.baseSellingPrice,
    this.isActive = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'servings_per_recipe': servingsPerRecipe,
      'base_selling_price': baseSellingPrice,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      servingsPerRecipe: map['servings_per_recipe'],
      baseSellingPrice: map['base_selling_price'],
      isActive: map['is_active'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
