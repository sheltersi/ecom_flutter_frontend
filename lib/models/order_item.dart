import 'package:flutter_learn2/models/product.dart';

/// A line item inside an order: the product, quantity ordered, and unit price at time of purchase.
class OrderItem {
  final Product product;
  final int quantity;
  final double price; // unit price frozen at order time

  const OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  /// Convenience getter for `price * quantity`.
  double get lineTotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      quantity: (json['quantity'] as int?) ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}
