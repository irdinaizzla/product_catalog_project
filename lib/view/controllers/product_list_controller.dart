import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';
import '../../data/items/product_item.dart';

enum ViewState { loading, success, empty, error }

/// Drives the product list screen: pagination (via 'skip')
/// debounced search (via the DummyJSON '/search' endpoint)
/// the loading/success/empty/error state the screen renders.
class ProductListController extends ChangeNotifier {
  ProductListController({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;
  static const int _pageSize = 20;
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  final List<Product> products = [];
  ViewState state = ViewState.loading;
  String errorMessage = '';
  bool isLoadingMore = false;

  bool _hasMore = true;
  int _skip = 0;
  String _query = '';
  Timer? _debounceTimer;
  int _requestId = 0;

  bool get hasMore => _hasMore;
  String get query => _query;

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
      state = products.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      if (currentRequest != _requestId) return;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = ViewState.error;
    } finally {
      if (currentRequest == _requestId) notifyListeners();
    }
  }

  Future<ProductListResult> _fetchPage() {
    return _query.isEmpty
        ? _repository.fetchProducts(limit: _pageSize, skip: _skip)
        : _repository.searchProducts(_query, limit: _pageSize, skip: _skip);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}