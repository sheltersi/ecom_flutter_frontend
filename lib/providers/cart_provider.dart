import 'package:flutter/material.dart';
import 'package:flutter_learn2/services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  bool _loading = false;

  List<dynamic> get items => _items;
  bool get loading => _loading;
  int get count => _items.fold<int>(0, (sum, i) => sum + ((i['quantity'] as int?) ?? 0));
  double get total {
    double t = 0;
    for (final item in _items) {
      final product = item['product'] as Map<String, dynamic>? ?? {};
      final qty = (item['quantity'] as int?) ?? 0;
      final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
      t += price * qty;
    }
    return t;
  }

  Future<void> fetchCart() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await ApiService.getCart();
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
