/// Represents a single product returned from the API.
class Product {
  final int id;
  final String title;
  final String description;
  final String brand;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.brand,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
  });

  /// Creates a [Product] from a JSON map, filling in safe defaults for missing/null fields.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: _toDouble(json['price']),
      discountPercentage: _toDouble(json['discountPercentage']),
      rating: _toDouble(json['rating']),
      stock: json['stock'] as int? ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      images:
      (json['images'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// A single page of products returned from the API, plus pagination metadata.
class ProductListResult {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductListResult({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + products.length < total;
}