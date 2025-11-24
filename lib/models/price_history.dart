class PriceHistory {
  final int? id;
  final int ingredientId;
  final double oldPrice;
  final double newPrice;
  final int changedAt;

  PriceHistory({
    this.id,
    required this.ingredientId,
    required this.oldPrice,
    required this.newPrice,
    required this.changedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ingredient_id': ingredientId,
      'old_price': oldPrice,
      'new_price': newPrice,
      'changed_at': changedAt,
    };
  }

  factory PriceHistory.fromMap(Map<String, dynamic> map) {
    return PriceHistory(
      id: map['id'],
      ingredientId: map['ingredient_id'],
      oldPrice: map['old_price'],
      newPrice: map['new_price'],
      changedAt: map['changed_at'],
    );
  }
}
