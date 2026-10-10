import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/screens/wishlist/wishlist_screen.dart';
import 'package:e_project/widgets/laptop_card.dart';

void main() {
  group('Phase 7 — Wishlist Business Logic Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearWishlist();
      provider.clearCart();
    });

    test('Initial wishlist is empty', () {
      expect(provider.wishlistCount, equals(0));
      expect(provider.wishlistProducts.isEmpty, isTrue);
    });

    test('User can save laptop to wishlist (toggle ♡ -> ♥)', () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      expect(provider.isInWishlist(hpLaptop.id), isFalse);

      provider.toggleWishlist(hpLaptop.id);

      expect(provider.isInWishlist(hpLaptop.id), isTrue);
      expect(provider.wishlistCount, equals(1));
      expect(provider.wishlistProducts.first.id, equals(hpLaptop.id));

      provider.toggleWishlist(hpLaptop.id);
      expect(provider.isInWishlist(hpLaptop.id), isFalse);
      expect(provider.wishlistCount, equals(0));
    });

    test('addToWishlist and removeFromWishlist work explicitly', () {
      final dellLaptop = provider.products.firstWhere((p) => p.brand == 'Dell');

      provider.addToWishlist(dellLaptop.id);
      expect(provider.isInWishlist(dellLaptop.id), isTrue);

      provider.removeFromWishlist(dellLaptop.id);
      expect(provider.isInWishlist(dellLaptop.id), isFalse);
    });

    test('Add to Cart from Wishlist item works properly', () {
      final macbook =
          provider.products.firstWhere((p) => p.name.contains('MacBook'));
      provider.addToWishlist(macbook.id);
      expect(provider.cartCount, equals(0));

      provider.addToCart(macbook.id, 1);
      expect(provider.cartCount, equals(1));
      expect(provider.cartItems.first.product.id, equals(macbook.id));
    });
  });

  group('Phase 7 — Heart Icon Toggle UI Verification', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearWishlist();
    });

    testWidgets(
        'LaptopCard toggles heart icon from ♡ (favorite_border) to ♥ (favorite)',
        (tester) async {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LaptopCard(product: hpLaptop),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(provider.isInWishlist(hpLaptop.id), isTrue);

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(provider.isInWishlist(hpLaptop.id), isFalse);
    });
  });

  group('Phase 7 — WishlistScreen UI Verification', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearWishlist();
      provider.clearCart();
    });

    testWidgets(
        'Empty wishlist displays friendly empty state and Explore button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WishlistScreen(),
        ),
      );

      expect(find.text('Your Wishlist is Empty'), findsOneWidget);
      expect(find.text('Explore Laptops'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets(
        'WishlistScreen shows Product image, Name, Price, Rating, Add to Cart, Remove',
        (tester) async {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToWishlist(hpLaptop.id);

      await tester.pumpWidget(
        const MaterialApp(
          home: WishlistScreen(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('HP EliteBook'), findsAtLeastNWidgets(1));

      expect(find.text('Rs. 95,000'), findsOneWidget);

      expect(find.textContaining('4.5'), findsAtLeastNWidgets(1));

      expect(find.text('Add to Cart'), findsOneWidget);

      expect(find.text('Remove'), findsOneWidget);

      await tester.tap(find.text('Add to Cart'));
      await tester.pump();

      expect(provider.cartCount, equals(1));
      expect(provider.cartItems.first.product.id, equals(hpLaptop.id));

      await tester.tap(find.text('Remove'));
      await tester.pump();

      expect(provider.wishlistCount, equals(0));
      expect(find.text('Your Wishlist is Empty'), findsOneWidget);
    });
  });
}
