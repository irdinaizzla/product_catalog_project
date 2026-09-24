import '../lib/data/items/product_item.dart';
import '../lib/data/models/product.dart';

Product makeProduct(
    int id, {
      double price = 10,
      String title = 'Item',
    }) {
  return Product(
    id: id,
    title: title,
    description: '',
    brand: '',
    category: '',
    price: price,
    discountPercentage: 0,
    rating: 4,
    stock: 5,
    thumbnail: '',
    images: const [],
  );
}

/// Pretends to be the API. Slices a fixed list into pages.
class FakeRepository extends ProductRepository {
  FakeRepository(this.all);

  final List<Product> all;
  int fetchCalls = 0;

  ProductListResult _page(List<Product> source, int limit, int skip) {
    final slice = source.skip(skip).take(limit).toList();
    return ProductListResult(
      products: slice,
      total: source.length,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<ProductListResult> fetchProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    fetchCalls++;
    return _page(all, limit, skip);
  }

  @override
  Future<ProductListResult> searchProducts(
      String query, {
        int limit = 20,
        int skip = 0,
        String? sortBy,
        String? order,
      }) async {
    final matches = all
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _page(matches, limit, skip);
  }
}

/// Always fails, for testing the error state.
class ThrowingRepository extends ProductRepository {
  @override
  Future<ProductListResult> fetchProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    throw Exception('boom');
  }
}