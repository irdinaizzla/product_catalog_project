import 'package:flutter_test/flutter_test.dart';

import '../lib/view/controllers/cart_controller.dart';
import 'test_helpers.dart';

void main() {
  final cart = CartController.instance;

  // The cart is a singleton, so wipe it before every test.
  setUp(() => cart.clear());

  test('starts empty', () {
    expect(cart.isEmpty, isTrue);
    expect(cart.totalItems, 0);
    expect(cart.subtotal, 0);
  });

  test('add puts one unit in the bag', () {
    cart.add(makeProduct(1, price: 5));
    expect(cart.quantityOf(1), 1);
    expect(cart.totalItems, 1);
  });

  test('adding the same product twice increases quantity', () {
    final p = makeProduct(1, price: 5);
    cart.add(p);
    cart.add(p);
    expect(cart.quantityOf(1), 2);
    expect(cart.items.length, 1);
  });

  test('subtotal adds up every line', () {
    cart.add(makeProduct(1, price: 5));
    cart.add(makeProduct(1, price: 5));
    cart.add(makeProduct(2, price: 10));
    expect(cart.subtotal, 20);
    expect(cart.totalItems, 3);
  });

  test('decrement removes the item at zero', () {
    cart.add(makeProduct(1));
    cart.decrement(1);
    expect(cart.quantityOf(1), 0);
    expect(cart.isEmpty, isTrue);
  });

  test('increment does nothing for a product not in the bag', () {
    cart.increment(99);
    expect(cart.isEmpty, isTrue);
  });

  test('remove and clear work', () {
    cart.add(makeProduct(1));
    cart.add(makeProduct(2));
    cart.remove(1);
    expect(cart.quantityOf(1), 0);
    expect(cart.quantityOf(2), 1);
    cart.clear();
    expect(cart.isEmpty, isTrue);
  });

  test('notifies listeners when the bag changes', () {
    var calls = 0;
    void listener() => calls++;
    cart.addListener(listener);

    cart.add(makeProduct(1));
    cart.increment(1);
    cart.decrement(1);

    expect(calls, 3);
    cart.removeListener(listener);
  });
}