import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../../data/items/product_item.dart';
import '../widgets/state_widgets.dart';

/// Screen that fetches and displays the full details for a single product.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Product>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _retry,
            );
          }
          final product = snapshot.data;
          if (product == null) {
            return const EmptyView(message: 'Product not found.');
          }
          return _DetailBody(product: product);
        },
      ),
    );
  }
}

/// Displays the loaded product's images, title, price, rating, and description.
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final images = product.images.isNotEmpty ? product.images : [product.thumbnail];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) => Image.network(
              images[index],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 48),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.star_rounded, size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(product.rating.toStringAsFixed(1), style: textTheme.bodyMedium),
                ],
              ),
              if (product.brand.isNotEmpty || product.category.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (product.brand.isNotEmpty) Chip(label: Text(product.brand)),
                    if (product.category.isNotEmpty) Chip(label: Text(product.category)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text('Description', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(product.description, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
