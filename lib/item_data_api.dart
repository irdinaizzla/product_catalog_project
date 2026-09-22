import 'service_api.dart';

class ItemDataApi {
  /// Get products
  ///
  /// GET https://dummyjson.com/products?limit=20&skip=0
  static Future<Map<String, dynamic>> getProducts({
    int limit = 20,
    int skip = 0,
  }) {
    return ServiceApi.get(
      'products',
      queryParams: {
        'limit': limit.toString(),
        'skip': skip.toString(),
      },
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
  /// GET https://dummyjson.com/products/search?q=phone
  static Future<Map<String, dynamic>> searchProducts(
      String query, {
        int? limit,
        int? skip,
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

    return ServiceApi.get(
      'products/search',
      queryParams: queryParams,
    );
  }
}