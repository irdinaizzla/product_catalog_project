import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';
import '../../data/items/product_item.dart';

enum ViewState { loading, success, empty, error }

enum SortOption {
  relevance('Default', null, null),
  priceLow('Price: Low to High', 'price', 'asc'),
  priceHigh('Price: High to Low', 'price', 'desc'),
  nameAZ('Name: A to Z', 'title', 'asc'),
  nameZA('Name: Z to A', 'title', 'desc');

  const SortOption(this.label, this.sortBy, this.order);

  final String label;
  final String? sortBy;
  final String? order;
}

class ProductListController extends ChangeNotifier {
  ProductListController({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;
  static const int _pageSize = 20;
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  static const int _minVisible = 8;

  /// All products loaded so far (before the price filter is applied).
  final List<Product> products = [];
  ViewState state = ViewState.loading;
  String errorMessage = '';
  bool isLoadingMore = false;

  SortOption sort = SortOption.relevance;
  double? minPrice;
  double? maxPrice;

  bool _hasMore = true;
  int _skip = 0;
  String _query = '';
  Timer? _debounceTimer;
  int _requestId = 0;

  bool get hasMore => _hasMore;
  String get query => _query;

  bool get isPriceFiltered => minPrice != null || maxPrice != null;
  bool get hasActiveFilters => isPriceFiltered || sort != SortOption.relevance;

  /// The products the screen should show (loaded products + price filter).
  List<Product> get visibleProducts {
    final min = minPrice;
    final max = maxPrice;
    if (min == null && max == null) return products;
    return products
        .where((p) =>
    (min == null || p.price >= min) && (max == null || p.price <= max))
        .toList();
  }

  Future<void> loadInitial() => _load(reset: true);

  Future<void> retry() => _load(reset: true);

  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore || state == ViewState.loading) return;
    isLoadingMore = true;
    notifyListeners();

    final currentRequest = _requestId;
    try {
      final result = await _fetchPage();
      if (currentRequest != _requestId) return; // superseded by a reset/search

      products.addAll(result.products);
      _skip += result.products.length;
      _hasMore = result.hasMore;

      if (!await _fillFiltered(currentRequest)) return;
    } catch (_) {
      // Keep existing results on a "load more" failure
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_searchDebounce, () {
      _query = query.trim();
      _load(reset: true);
    });
  }

  /// Changes the sort order and reloads from the first page.
  void setSort(SortOption option) {
    if (option == sort) return;
    sort = option;
    _load(reset: true);
  }

  /// Applies a price range filter. Pass null for "no minimum" / "no maximum".
  Future<void> setPriceRange({double? min, double? max}) async {
    if (min == minPrice && max == maxPrice) return;
    minPrice = min;
    maxPrice = max;

    final needsFetch = isPriceFiltered &&
        visibleProducts.length < _minVisible &&
        _hasMore;

    if (!needsFetch) {
      state = visibleProducts.isEmpty ? ViewState.empty : ViewState.success;
      notifyListeners();
      return;
    }

    _requestId++;
    final currentRequest = _requestId;
    state = ViewState.loading;
    notifyListeners();

    try {
      if (!await _fillFiltered(currentRequest)) return;
      state = visibleProducts.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      if (currentRequest != _requestId) return;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = ViewState.error;
    } finally {
      if (currentRequest == _requestId) notifyListeners();
    }
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      _skip = 0;
      _hasMore = true;
      products.clear();
    }

    _requestId++;
    final currentRequest = _requestId;
    state = ViewState.loading;
    notifyListeners();

    try {
      final result = await _fetchPage();
      if (currentRequest != _requestId) return;

      products.addAll(result.products);
      _skip += result.products.length;
      _hasMore = result.hasMore;

      if (!await _fillFiltered(currentRequest)) return;

      state = visibleProducts.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      if (currentRequest != _requestId) return;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = ViewState.error;
    } finally {
      if (currentRequest == _requestId) notifyListeners();
    }
  }

  Future<bool> _fillFiltered(int currentRequest) async {
    var guard = 0;
    while (isPriceFiltered &&
        visibleProducts.length < _minVisible &&
        _hasMore &&
        guard < 15) {
      guard++;
      final result = await _fetchPage();
      if (currentRequest != _requestId) return false;

      products.addAll(result.products);
      _skip += result.products.length;
      _hasMore = result.hasMore;
    }
    return true;
  }

  Future<ProductListResult> _fetchPage() {
    final sortBy = sort.sortBy;
    final order = sort.order;
    return _query.isEmpty
        ? _repository.fetchProducts(
      limit: _pageSize,
      skip: _skip,
      sortBy: sortBy,
      order: order,
    )
        : _repository.searchProducts(
      _query,
      limit: _pageSize,
      skip: _skip,
      sortBy: sortBy,
      order: order,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}