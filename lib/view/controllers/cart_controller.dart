import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';

/// One line in the bag: a product and how many of it.
class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get lineTotal => product.price * quantity;
}

/// Holds the shopping bag in memory (cleared when the app closes).
class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final Map<int, CartItem> _items = {};

  /// Items in the order they were added.
  List<CartItem> get items => _items.values.toList(growable: false);

  bool get isEmpty => _items.isEmpty;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  /// Adds one unit of [product] (or increases its quantity).
  void add(Product product) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void increment(int productId) {
    final item = _items[productId];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  /// Decreases the quantity; removes the item when it reaches zero.
  void decrement(int productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void remove(int productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}