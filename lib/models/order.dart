import 'package:flutter_learn2/models/order_item.dart';

/// A completed (or in-progress) order containing line items, status, and total.
class Order {
  final int id;
  final String status; // "pending", "confirmed", "delivered", "cancelled"
  final double total;
  final String createdAt; // ISO-8601 timestamp
  final List<OrderItem> items;

  const Order({
    required this.id,
    this.status = 'pending',
    this.total = 0,
    this.createdAt = '',
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    return Order(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      items: rawItems
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
