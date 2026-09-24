import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/cart_controller.dart';
import '../widgets/fancy_widgets.dart';
import '../widgets/state_widgets.dart';

/// Shows everything in the bag. View-only: no payment or checkout.
class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final media = MediaQuery.of(context);
    final top = media.padding.top + kToolbarHeight + 8;

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
          'My Bag',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (context, _) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: cart.clear,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.rose,
                  ),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            if (cart.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: top),
                child: EmptyView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your bag is empty',
                  message: 'Add something you love and it will show up here.',
                  actionLabel: 'Keep browsing',
                  onAction: () => Navigator.of(context).maybePop(),
                ),
              );
            }

            final items = cart.items;
            return Stack(
              children: [
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, top, 16, 200),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _BagItemTile(
                    key: ValueKey('bag-${items[index].product.id}'),
                    item: items[index],
                    index: index,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16 + media.padding.bottom,
                  child: _SummaryCard(cart: cart),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BagItemTile extends StatelessWidget {
  const _BagItemTile({super.key, required this.item, required this.index});

  final CartItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final product = item.product;

    return FadeSlideIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Dismissible(
          key: ValueKey('dismiss-${product.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => cart.remove(product.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 26),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: GlassContainer(
            radius: 24,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.blue.withValues(alpha: 0.45),
                        AppColors.pink.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                  child: NetImage(product.thumbnail),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${product.price.toStringAsFixed(2)} each',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.navy.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _QuantityStepper(
                            quantity: item.quantity,
                            onMinus: () => cart.decrement(product.id),
                            onPlus: () => cart.increment(product.id),
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '\$${item.lineTotal.toStringAsFixed(2)}',
                              key: ValueKey(item.lineTotal),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIcon(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            onTap: onMinus,
          ),
          SizedBox(
            width: 30,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  '$quantity',
                  key: ValueKey(quantity),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
          _RoundIcon(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.85,
      hoverScale: 1.12,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.pink.withValues(alpha: 0.4),
        ),
        child: Icon(icon, size: 16, color: AppColors.navy),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 30,
      blur: 14,
      opacity: 0.7,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Items', value: '${cart.totalItems}'),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${cart.subtotal.toStringAsFixed(2)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: AppColors.navy.withValues(alpha: 0.12),
            ),
          ),
          _SummaryRow(
            label: 'Total',
            value: '\$${cart.subtotal.toStringAsFixed(2)}',
            big: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.big = false,
  });

  final String label;
  final String value;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: big ? 16 : 14,
            fontWeight: big ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.navy.withValues(alpha: big ? 1 : 0.65),
          ),
        ),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            value,
            key: ValueKey(value),
            style: GoogleFonts.poppins(
              fontSize: big ? 22 : 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}