import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/product.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/fancy_widgets.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadInitial();
    _scrollController.addListener(_onScroll);
    _searchFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Rebuilds the screen whenever the controller's state changes.
  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  /// Triggers loading the next page once the user scrolls near the bottom.
  void _onScroll() {
    if (_scrollController.positions.length != 1) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearch(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey(_controller.state),
                    child: _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Beauty Essentials',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lobsterTwo(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: AppColors.navy,
                shadows: [
                  Shadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final focused = _searchFocus.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: focused ? 0.9 : 0.6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: focused ? AppColors.pink : Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: focused
                  ? AppColors.pink.withValues(alpha: 0.4)
                  : AppColors.navy.withValues(alpha: 0.06),
              blurRadius: focused ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.navy),
          decoration: InputDecoration(
            hintText: 'Search products…',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.navy.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.navy.withValues(alpha: 0.6),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.navy.withValues(alpha: 0.6),
              onPressed: () {
                _searchController.clear();
                setState(() {});
                _controller.onSearchChanged('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
            _controller.onSearchChanged(value);
          },
        ),
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
          color: AppColors.rose,
          backgroundColor: Colors.white,
          onRefresh: _controller.retry,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount:
            _controller.products.length + (_controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _controller.products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.rose,
                      ),
                    ),
                  ),
                );
              }
              final Product product = _controller.products[index];
              return ProductCard(
                index: index,
                product: product,
                onTap: () => Navigator.of(context).push(
                  fadeSlideRoute(
                    ProductDetailScreen(
                      productId: product.id,
                      preview: product,
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}