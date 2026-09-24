import '../api/item_data_api.dart';
import '../models/product.dart';

/// Provides access to product data, wrapping the raw API responses into typed [Product] and [ProductListResult] models.
class ProductRepository {
  /// Fetches a page of all products (optionally sorted).
  Future<ProductListResult> fetchProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    final json = await ItemDataApi.getProducts(
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
    return _parseListResponse(json, fallbackSkip: skip, fallbackLimit: limit);
  }

  Future<ProductListResult> searchProducts(
      String query, {
        int limit = 20,
        int skip = 0,
        String? sortBy,
        String? order,
      }) async {
    final json = await ItemDataApi.searchProducts(
      query,
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
    return _parseListResponse(json, fallbackSkip: skip, fallbackLimit: limit);
  }

  /// Fetches full details for a single product by its ID.
  Future<Product> fetchProductDetail(int id) async {
    final json = await ItemDataApi.getProductDetail(id);
    return Product.fromJson(json);
  }

  ProductListResult _parseListResponse(
      Map<String, dynamic> json, {
        required int fallbackSkip,
        required int fallbackLimit,
      }) {
    final rawProducts = json['products'] as List? ?? const [];
    final products = rawProducts
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();

    return ProductListResult(
      products: products,
      total: json['total'] as int? ?? products.length,
      skip: json['skip'] as int? ?? fallbackSkip,
      limit: json['limit'] as int? ?? fallbackLimit,
    );
  }
}