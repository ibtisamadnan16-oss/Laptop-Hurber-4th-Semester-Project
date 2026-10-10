import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/screens/cart/cart_screen.dart';

void main() {
  group('Phase 6 — Shopping Cart Business Logic Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearCart();
    });

    test('Initial cart is empty with zero calculations', () {
      expect(provider.cartItems.isEmpty, isTrue);
      expect(provider.cartCount, equals(0));
      expect(provider.cartSubtotal, equals(0.0));
      expect(provider.cartShipping, equals(0.0));
      expect(provider.cartTax, equals(0.0));
      expect(provider.cartTotal, equals(0.0));
    });

    test('Add item to cart and calculate subtotal, shipping, tax, total', () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      expect(hpLaptop.price, equals(95000.0));

      provider.addToCart(hpLaptop.id, 1);

      expect(provider.cartCount, equals(1));
      expect(provider.cartItems.length, equals(1));
      expect(provider.cartItems.first.product.id, equals(hpLaptop.id));
      expect(provider.cartItems.first.quantity, equals(1));

      expect(provider.cartSubtotal, equals(95000.0));
      expect(provider.formattedSubtotal, equals('Rs. 95,000'));

      expect(provider.cartShipping, equals(500.0));
      expect(provider.formattedShipping, equals('Rs. 500'));

      expect(provider.cartTax, equals(2000.0));
      expect(provider.formattedTax, equals('Rs. 2,000'));

      expect(provider.cartTotal, equals(97500.0));
      expect(provider.formattedTotal, equals('Rs. 97,500'));
    });

    test('Increase quantity multiplies item price and recalculates subtotal',
        () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      provider.increaseQuantity(hpLaptop.id);

      expect(provider.cartCount, equals(2));
      expect(provider.cartItems.first.quantity, equals(2));
      expect(provider.cartSubtotal, equals(190000.0));
      expect(provider.formattedSubtotal, equals('Rs. 190,000'));
      expect(provider.cartShipping, equals(500.0));
      expect(provider.cartTax, equals(2000.0));
      expect(provider.cartTotal, equals(192500.0));
      expect(provider.formattedTotal, equals('Rs. 192,500'));
    });

    test('Decrease quantity reduces item count', () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 2);

      provider.decreaseQuantity(hpLaptop.id);

      expect(provider.cartCount, equals(1));
      expect(provider.cartItems.first.quantity, equals(1));
      expect(provider.cartSubtotal, equals(95000.0));
    });

    test('Decrease quantity from 1 removes item from cart', () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      provider.decreaseQuantity(hpLaptop.id);

      expect(provider.cartItems.isEmpty, isTrue);
      expect(provider.cartCount, equals(0));
      expect(provider.cartTotal, equals(0.0));
    });

    test('Remove item directly removes it from cart', () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 3);

      provider.removeFromCart(hpLaptop.id);

      expect(provider.cartItems.isEmpty, isTrue);
      expect(provider.cartCount, equals(0));
      expect(provider.cartSubtotal, equals(0.0));
      expect(provider.cartTotal, equals(0.0));
    });

    test('Clear cart removes all items', () {
      final laptops = provider.products.take(3).toList();
      for (final l in laptops) {
        provider.addToCart(l.id, 1);
      }
      expect(provider.cartCount, equals(3));

      provider.clearCart();

      expect(provider.cartCount, equals(0));
      expect(provider.cartItems.isEmpty, isTrue);
    });
  });

  group('Phase 6 — CartScreen UI & Wireframe Verification', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearCart();
    });

    testWidgets('Empty cart displays friendly empty state and Explore button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartScreen(),
        ),
      );

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Explore Laptops'), findsOneWidget);
      expect(find.byIcon(Icons.remove_shopping_cart_outlined), findsOneWidget);
    });

    testWidgets(
        'Cart with HP EliteBook displays exact wireframe elements and performs actions',
        (tester) async {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      await tester.pumpWidget(
        const MaterialApp(
          home: CartScreen(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('HP EliteBook'), findsAtLeastNWidgets(1));
      expect(find.text('Rs. 95,000'), findsAtLeastNWidgets(1));

      expect(find.text('Quantity:'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.add), findsOneWidget);

      expect(find.text('Remove'), findsOneWidget);

      expect(find.text('Subtotal:'), findsOneWidget);
      expect(find.text('Shipping:'), findsOneWidget);
      expect(find.text('Rs. 500'), findsOneWidget);
      expect(find.text('Tax:'), findsOneWidget);
      expect(find.text('Rs. 2,000'), findsOneWidget);
      expect(find.text('Total:'), findsOneWidget);
      expect(find.text('Rs. 97,500'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('Rs. 190,000'), findsOneWidget);
      expect(find.text('Rs. 192,500'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('Rs. 97,500'), findsOneWidget);

      await tester.tap(find.text('Remove'));
      await tester.pump();

      expect(find.text('Your Cart is Empty'), findsOneWidget);
    });
  });
}
