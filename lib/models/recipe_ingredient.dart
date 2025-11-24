class RecipeIngredient {
  final int? id;
  final int menuItemId;
  final int ingredientId;
  final double quantity;
  final String unit;
  final String? notes;

  RecipeIngredient({
    this.id,
    required this.menuItemId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id'],
      menuItemId: map['menu_item_id'],
      ingredientId: map['ingredient_id'],
      quantity: map['quantity'],
      unit: map['unit'],
      notes: map['notes'],
    );
  }
}
