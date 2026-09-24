import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/product.dart';
import '../../data/items/product_item.dart';
import '../controllers/cart_controller.dart';
import '../widgets/fancy_widgets.dart';
import '../widgets/state_widgets.dart';
import 'bag_screen.dart';

/// Screen that fetches and displays the full details for a single product.
///
/// Pass [preview] (the product already loaded in the list) to show content
/// instantly and enable the hero image animation while the details load.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.preview,
  });

  final int productId;
  final Product? preview;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _repository = ProductRepository();
  late Future<Product> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchProductDetail(widget.productId);
  }

  /// Re-triggers the product fetch, used to retry after an error.
  void _retry() {
    setState(() {
      _future = _repository.fetchProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 70,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Center(child: GlassBackButton()),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: BagButton(size: 42)),
          ),
        ],
      ),
      body: AppBackground(
        child: FutureBuilder<Product>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              final preview = widget.preview;
              if (preview != null) {
                return _DetailBody(key: ValueKey(preview.id), product: preview);
              }
              return const DetailSkeleton();
            }
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(top: topInset),
                child: ErrorView(
                  message: snapshot.error
                      .toString()
                      .replaceFirst('Exception: ', ''),
                  onRetry: _retry,
                ),
              );
            }
            final product = snapshot.data;
            if (product == null) {
              return Padding(
                padding: EdgeInsets.only(top: topInset),
                child: const EmptyView(message: 'Product not found.'),
              );
            }
            return _DetailBody(key: ValueKey(product.id), product: product);
          },
        ),
      ),
    );
  }
}

/// Displays the loaded product's images, title, price, rating, and description.
class _DetailBody extends StatefulWidget {
  const _DetailBody({super.key, required this.product});

  final Product product;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final media = MediaQuery.of(context);
    final top = media.padding.top + kToolbarHeight + 8;
    final images =
    product.images.isNotEmpty ? product.images : [product.thumbnail];
    final hasDiscount = product.discountPercentage >= 1;
    final oldPrice = hasDiscount
        ? product.price / (1 - product.discountPercentage / 100)
        : null;

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, top, 16, 120),
          children: [
            FadeSlideIn(index: 0, child: _buildGallery(images)),
            const SizedBox(height: 20),
            FadeSlideIn(
              index: 1,
              child: _buildHeader(product, hasDiscount, oldPrice),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              index: 2,
              child: Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.star,
                      value: product.rating.toStringAsFixed(1),
                      label: 'Rating',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.inventory_2_rounded,
                      iconColor: AppColors.rose,
                      value: product.stock > 0 ? '${product.stock}' : 'Sold out',
                      label: 'In stock',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.local_offer_rounded,
                      iconColor: const Color(0xFF6BB7D6),
                      value: hasDiscount
                          ? '${product.discountPercentage.round()}%'
                          : '—',
                      label: 'Discount',
                    ),
                  ),
                ],
              ),
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: 18),
              FadeSlideIn(
                index: 3,
                child: GlassContainer(
                  radius: 28,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.navy.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16 + media.padding.bottom,
          child: _buildBottomBar(product),
        ),
      ],
    );
  }

  Widget _buildGallery(List<String> images) {
    return GlassContainer(
      radius: 32,
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final image = Padding(
                  padding: const EdgeInsets.all(24),
                  child: NetImage(images[index]),
                );
                if (index != 0) return image;
                return Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: image,
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: active
                            ? AppColors.navy
                            : AppColors.navy.withValues(alpha: 0.25),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Product product, bool hasDiscount, double? oldPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.brand.isNotEmpty)
              _Pill(text: product.brand, color: AppColors.blue),
            if (product.category.isNotEmpty)
              _Pill(text: product.category, color: AppColors.pink),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            if (hasDiscount && oldPrice != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '\$${oldPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.navy.withValues(alpha: 0.45),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.orange, AppColors.pink],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '-${product.discountPercentage.round()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(Product product) {
    final cart = CartController.instance;

    return GlassContainer(
      radius: 30,
      blur: 14,
      opacity: 0.7,
      padding: const EdgeInsets.fromLTRB(22, 12, 12, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.navy.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const Spacer(),
          ListenableBuilder(
            listenable: cart,
            builder: (context, _) {
              final qty = cart.quantityOf(product.id);
              final inBag = qty > 0;
              return PressableScale(
                onTap: () {
                  if (inBag) {
                    Navigator.of(context)
                        .push(fadeSlideRoute(const BagScreen()));
                  } else {
                    cart.add(product);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: inBag
                          ? const [Color(0xFFBFE8D2), AppColors.blue]
                          : const [AppColors.pink, AppColors.orange],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: (inBag ? AppColors.blue : AppColors.pink)
                            .withValues(alpha: 0.55),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      key: ValueKey('$inBag-$qty'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          inBag
                              ? Icons.check_rounded
                              : Icons.shopping_bag_outlined,
                          color: AppColors.navy,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          inBag ? 'View bag ($qty)' : 'Add to bag',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 22,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.navy.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}