import 'package:flutter_test/flutter_test.dart';

import '../lib/view/controllers/product_list_controller.dart';
import 'test_helpers.dart';

void main() {
  List products(int count) => List.generate(
    count,
        (i) => makeProduct(i + 1, price: (i + 1).toDouble(), title: 'Item ${i + 1}'),
  );

  test('loadInitial gives success with the first page', () async {
    final c = ProductListController(repository: FakeRepository([...products(50)].cast()));
    await c.loadInitial();

    expect(c.state, ViewState.success);
    expect(c.products.length, 20);
    expect(c.hasMore, isTrue);
    c.dispose();
  });

  test('empty result gives the empty state', () async {
    final c = ProductListController(repository: FakeRepository([]));
    await c.loadInitial();

    expect(c.state, ViewState.empty);
    c.dispose();
  });

  test('a failing repository gives the error state with a clean message', () async {
    final c = ProductListController(repository: ThrowingRepository());
    await c.loadInitial();

    expect(c.state, ViewState.error);
    expect(c.errorMessage, 'boom');
    c.dispose();
  });

  test('loadMore appends the next page', () async {
    final c = ProductListController(repository: FakeRepository([...products(50)].cast()));
    await c.loadInitial();
    await c.loadMore();

    expect(c.products.length, 40);
    c.dispose();
  });

  test('loadMore stops when there is nothing left', () async {
    final c = ProductListController(repository: FakeRepository([...products(20)].cast()));
    await c.loadInitial();

    expect(c.hasMore, isFalse);
    await c.loadMore();
    expect(c.products.length, 20);
    c.dispose();
  });

  test('search is debounced and filters results', () async {
    final repo = FakeRepository([
      makeProduct(1, title: 'Lipstick'),
      makeProduct(2, title: 'Mascara'),
      makeProduct(3, title: 'Lip balm'),
    ]);
    final c = ProductListController(repository: repo);
    await c.loadInitial();

    c.onSearchChanged('lip');
    await Future.delayed(const Duration(milliseconds: 600));

    expect(c.query, 'lip');
    expect(c.products.length, 2);
    c.dispose();
  });

  test('setSort to the same option does not reload', () async {
    final repo = FakeRepository([...products(5)].cast());
    final c = ProductListController(repository: repo);
    await c.loadInitial();
    final before = repo.fetchCalls;

    c.setSort(SortOption.relevance);
    expect(repo.fetchCalls, before);
    c.dispose();
  });

  test('setSort to a new option reloads', () async {
    final repo = FakeRepository([...products(5)].cast());
    final c = ProductListController(repository: repo);
    await c.loadInitial();
    final before = repo.fetchCalls;

    c.setSort(SortOption.priceLow);
    await Future.delayed(const Duration(milliseconds: 50));
    expect(repo.fetchCalls, greaterThan(before));
    expect(c.sort, SortOption.priceLow);
    c.dispose();
  });

  test('price filter keeps fetching pages until enough items match', () async {
    // prices are 1..100, first page (1-20) has nothing >= 50
    final repo = FakeRepository([...products(100)].cast());
    final c = ProductListController(repository: repo);
    await c.loadInitial();

    await c.setPriceRange(min: 50);

    expect(c.isPriceFiltered, isTrue);
    expect(c.visibleProducts.length, greaterThanOrEqualTo(8));
    expect(c.visibleProducts.every((p) => p.price >= 50), isTrue);
    c.dispose();
  });

  test('price filter with no matches ends in the empty state', () async {
    final c = ProductListController(repository: FakeRepository([...products(10)].cast()));
    await c.loadInitial();

    await c.setPriceRange(min: 500);

    expect(c.state, ViewState.empty);
    c.dispose();
  });

  test('clearing the price filter shows everything again', () async {
    final c = ProductListController(repository: FakeRepository([...products(10)].cast()));
    await c.loadInitial();

    await c.setPriceRange(min: 5);
    await c.setPriceRange();

    expect(c.isPriceFiltered, isFalse);
    expect(c.visibleProducts.length, 10);
    c.dispose();
  });
}