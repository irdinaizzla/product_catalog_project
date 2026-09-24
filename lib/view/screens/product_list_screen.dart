import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/state_widgets.dart';
import 'product_detail_screen.dart';

/// Screen showing a searchable, infinite-scrolling list of products.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductListController _controller = ProductListController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Rebuilds the screen whenever the controller's state changes.
  void _onControllerChanged() => setState(() {});

  /// Triggers loading the next page once the user scrolls near the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _controller.onSearchChanged,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_controller.state) {
      case ViewState.loading:
        return const LoadingView();
      case ViewState.error:
        return ErrorView(
          message: _controller.errorMessage,
          onRetry: _controller.retry,
        );
      case ViewState.empty:
        return EmptyView(
          message: _controller.query.isEmpty
              ? 'No products found.'
              : 'No products match "${_controller.query}".',
        );
      case ViewState.success:
        return RefreshIndicator(
          onRefresh: _controller.retry,
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
            _controller.products.length + (_controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _controller.products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final Product product = _controller.products[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}