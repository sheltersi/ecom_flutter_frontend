import 'package:flutter/material.dart';
import 'package:flutter_learn2/models/cart_item.dart';
import 'package:flutter_learn2/services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => _items;
  bool get loading => _loading;
  int get count => _items.fold<int>(0, (sum, i) => sum + i.quantity);
  double get total {
    double t = 0;
    for (final item in _items) {
      t += item.product.price * item.quantity;
    }
    return t;
  }

  Future<void> fetchCart() async {
    _loading = true;
    notifyListeners();
    try {
      final raw = await ApiService.getCart();
      _items = raw
          .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      await ApiService.addToCart(productId: productId, quantity: quantity);
      await fetchCart();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    try {
      await ApiService.updateCartItem(cartItemId, quantity);
      await fetchCart();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await ApiService.removeFromCart(cartItemId);
      await fetchCart();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> placeOrder() async {
    try {
      await ApiService.placeOrder();
      _items = [];
      notifyListeners();
    } on ApiException {
      rethrow;
    }
  }
}
