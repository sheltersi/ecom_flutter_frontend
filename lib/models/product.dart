import 'package:flutter_learn2/models/category.dart';

/// A grocery product with its metadata, stock level, optional image, and parent category.
class Product {
  final int id;
  final String name;
  final double price;
  final String unit; // e.g. "kg", "piece", "litre"
  final String? description;
  final int stock;
  final String? image; // relative image path (used with ApiService.imageUrl)
  final Category? category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.description,
    this.stock = 0,
    this.image,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      unit: json['unit'] as String? ?? 'piece',
      description: json['description'] as String?,
      stock: (json['stock'] as int?) ?? 0,
      image: json['image'] as String?,
      category: json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}
