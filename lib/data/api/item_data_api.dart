import 'service_api.dart';

class ItemDataApi {
  /// Get products
  ///
  /// GET https://dummyjson.com/products?limit=20&skip=0&sortBy=price&order=asc
  static Future<Map<String, dynamic>> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'skip': skip.toString(),
    };

    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (order != null) queryParams['order'] = order;

    return ServiceApi.get(
      'products',
      queryParams: queryParams,
    );
  }

  /// Get product detail
  ///
  /// GET https://dummyjson.com/products/{id}
  static Future<Map<String, dynamic>> getProductDetail(int id) {
    return ServiceApi.get(
      'products/$id',
    );
  }

  /// Search products
  ///
  /// GET https://dummyjson.com/products/search?q=phone&sortBy=title&order=asc
  static Future<Map<String, dynamic>> searchProducts(
      String query, {
        int? limit,
        int? skip,
        String? sortBy,
        String? order,
      }) {
    final queryParams = <String, String>{
      'q': query,
    };

    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    if (skip != null) {
      queryParams['skip'] = skip.toString();
    }

    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (order != null) queryParams['order'] = order;

    return ServiceApi.get(
      'products/search',
      queryParams: queryParams,
    );
  }
}