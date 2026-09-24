import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/product.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/fancy_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/state_widgets.dart';
import 'product_detail_screen.dart';

const double _priceCap = 1000;

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

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<RangeValues>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PriceFilterSheet(
        initial: RangeValues(
          _controller.minPrice ?? 0,
          _controller.maxPrice ?? _priceCap,
        ),
      ),
    );
    if (result == null) return;
    _controller.setPriceRange(
      min: result.start <= 0 ? null : result.start,
      max: result.end >= _priceCap ? null : result.end,
    );
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
              _buildSortChips(),
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
          const BagButton(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final focused = _searchFocus.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 10),
          _buildFilterButton(),
        ],
      ),
    );
  }

  /// Opens the price filter. Shows a dot when a price filter is active.
  Widget _buildFilterButton() {
    final active = _controller.isPriceFiltered;
    return PressableScale(
      onTap: _openFilterSheet,
      child: SizedBox(
        width: 54,
        height: 54,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: active
                        ? const [AppColors.pink, AppColors.orange]
                        : [
                      Colors.white.withValues(alpha: 0.75),
                      Colors.white.withValues(alpha: 0.5),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.navy),
              ),
            ),
            if (active)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.rose,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Horizontal chips to pick the sort order.
  Widget _buildSortChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: SortOption.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = SortOption.values[index];
          final selected = _controller.sort == option;
          return PressableScale(
            onTap: () => _controller.setSort(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: selected
                      ? const [AppColors.pink, AppColors.orange]
                      : [
                    Colors.white.withValues(alpha: 0.6),
                    Colors.white.withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? AppColors.pink.withValues(alpha: 0.45)
                        : Colors.transparent,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                option.label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _emptyMessage() {
    final base = _controller.query.isEmpty
        ? 'No products found.'
        : 'No products match "${_controller.query}".';
    return _controller.isPriceFiltered
        ? '$base\nTry widening your price range.'
        : base;
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
        return EmptyView(message: _emptyMessage());
      case ViewState.success:
        final items = _controller.visibleProducts;
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
            itemCount: items.length + (_controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
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
              final Product product = items[index];
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

/// Bottom sheet with a price range slider. Pops with the chosen range.
class _PriceFilterSheet extends StatefulWidget {
  const _PriceFilterSheet({required this.initial});

  final RangeValues initial;

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  late RangeValues _values = widget.initial;

  String get _label {
    final start = '\$${_values.start.round()}';
    final end = _values.end >= _priceCap
        ? '\$${_priceCap.round()}+'
        : '\$${_values.end.round()}';
    return '$start  –  $end';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Filter by price',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.rose,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.rose,
              inactiveTrackColor: AppColors.pink.withValues(alpha: 0.35),
              thumbColor: AppColors.rose,
              overlayColor: AppColors.rose.withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: RangeSlider(
              values: _values,
              min: 0,
              max: _priceCap,
              divisions: 100,
              onChanged: (v) => setState(() => _values = v),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(const RangeValues(0, _priceCap)),
                style: TextButton.styleFrom(foregroundColor: AppColors.rose),
                child: Text(
                  'Reset',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              PillButton(
                label: 'Apply',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.of(context).pop(_values),
              ),
            ],
          ),
        ],
      ),
    );
  }
}