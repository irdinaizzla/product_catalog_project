import 'package:flutter_test/flutter_test.dart';

import '../lib/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('fills safe defaults when fields are missing', () {
      final p = Product.fromJson({});
      expect(p.id, 0);
      expect(p.title, 'Untitled product');
      expect(p.price, 0.0);
      expect(p.images, isEmpty);
    });

    test('parses numbers even when they come as strings', () {
      final p = Product.fromJson({'id': 1, 'price': '12.5', 'rating': 4});
      expect(p.price, 12.5);
      expect(p.rating, 4.0);
    });

    test('keeps only string images', () {
      final p = Product.fromJson({
        'images': ['a.png', 5, null, 'b.png'],
      });
      expect(p.images, ['a.png', 'b.png']);
    });
  });

  group('ProductListResult.hasMore', () {
    test('true when there are more items on the server', () {
      final r = ProductListResult(products: [], total: 50, skip: 0, limit: 20);
      expect(r.hasMore, isTrue);
    });

    test('false on the last page', () {
      final r = ProductListResult(products: [], total: 0, skip: 0, limit: 20);
      expect(r.hasMore, isFalse);
    });
  });
}