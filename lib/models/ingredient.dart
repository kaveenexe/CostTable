class Ingredient {
  final int? id;
  final String name;
  final String baseUnit;
  final double currentPrice;
  final int lastUpdated;
  final String? supplier;
  final String? notes;
  final int createdAt;

  Ingredient({
    this.id,
    required this.name,
    required this.baseUnit,
    required this.currentPrice,
    required this.lastUpdated,
    this.supplier,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_unit': baseUnit,
      'current_price': currentPrice,
      'last_updated': lastUpdated,
      'supplier': supplier,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      baseUnit: map['base_unit'],
      currentPrice: map['current_price'],
      lastUpdated: map['last_updated'],
      supplier: map['supplier'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}
