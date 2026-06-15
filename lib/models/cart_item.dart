import 'package:flutter_learn2/models/product.dart';

/// An entry in the user's shopping cart: a product reference plus a quantity.
class CartItem {
  final int id; // cart-item row ID (not product ID)
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      quantity: (json['quantity'] as int?) ?? 0,
    );
  }
}
