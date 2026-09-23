import 'item_data_api.dart';
import 'product.dart';

/// Provides access to product data, wrapping the raw API responses into typed [Product] and [ProductListResult] models.
class ProductRepository {
  /// Fetches a page of all products.
  Future<ProductListResult> fetchProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final json = await ItemDataApi.getProducts(limit: limit, skip: skip);
    return _parseListResponse(json, fallbackSkip: skip, fallbackLimit: limit);
  }

  /// Fetches a page of products matching a search query.
  Future<ProductListResult> searchProducts(
      String query, {
        int limit = 20,
        int skip = 0,
      }) async {
    final json =
    await ItemDataApi.searchProducts(query, limit: limit, skip: skip);
    return _parseListResponse(json, fallbackSkip: skip, fallbackLimit: limit);
  }

  /// Fetches full details for a single product by its ID.
  Future<Product> fetchProductDetail(int id) async {
    final json = await ItemDataApi.getProductDetail(id);
    return Product.fromJson(json);
  }

  /// Converts a raw list-response JSON map into a [ProductListResult]
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