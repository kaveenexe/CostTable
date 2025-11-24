class CostComponent {
  final int? id;
  final String name;
  final String category; // 'DIRECT' or 'INDIRECT'
  final double amount;
  final int isPercentage; // 1=percentage, 0=fixed
  final int isActive;
  final String appliesTo; // 'ALL' or specific menu_item_id
  final String? notes;
  final int createdAt;

  CostComponent({
    this.id,
    required this.name,
    required this.category,
    required this.amount,
    this.isPercentage = 0,
    this.isActive = 1,
    this.appliesTo = 'ALL',
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'is_percentage': isPercentage,
      'is_active': isActive,
      'applies_to': appliesTo,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory CostComponent.fromMap(Map<String, dynamic> map) {
    return CostComponent(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      amount: map['amount'],
      isPercentage: map['is_percentage'],
      isActive: map['is_active'],
      appliesTo: map['applies_to'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}
