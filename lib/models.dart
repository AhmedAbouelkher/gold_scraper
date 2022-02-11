import 'package:cloud_firestore/cloud_firestore.dart';

class PriceUpdate {
  final double price;
  final DateTime updatedAt;

  const PriceUpdate({
    required this.price,
    required this.updatedAt,
  });

  factory PriceUpdate.fromMap(Map<String, dynamic> map) {
    return PriceUpdate(
      price: map['price']?.toDouble() ?? 0.0,
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() => 'PriceUpdate(price: $price, updatedAt: $updatedAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PriceUpdate && other.price == price && other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => price.hashCode ^ updatedAt.hashCode;
}
