import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/user_model.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/utils/validators.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 18 — Major Features Testing Suite', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearCart();
      provider.clearWishlist();
    });

    group('1. User Registration: Account successfully create ho', () {
      test('Validation passes for complete and valid registration data', () {
        expect(AppValidators.validateName('Muhammad Ali'), isNull);
        expect(AppValidators.validateEmail('ali.laptop@gmail.com'), isNull);
        expect(AppValidators.validatePassword('SecurePass123!'), isNull);
        expect(
            AppValidators.validateConfirmPassword(
                'SecurePass123!', 'SecurePass123!'),
            isNull);
        expect(AppValidators.validatePhone('+92 300 1234567'), isNull);
        expect(
            AppValidators.validateAddress('House 14, Street 5, PECHS, Karachi'),
            isNull);
      });

      test(
          'UserModel creates and serializes account data correctly for new registration',
          () {
        final newUser = UserModel(
          userId: 'user_reg_001',
          name: 'Muhammad Ali',
          email: 'ali.laptop@gmail.com',
          phone: '+92 300 1234567',
          address: 'House 14, Street 5, PECHS, Karachi',
          profileImage:
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
          role: 'user',
          createdAt: DateTime.now(),
        );

        expect(newUser.userId, equals('user_reg_001'));
        expect(newUser.name, equals('Muhammad Ali'));
        expect(newUser.email, equals('ali.laptop@gmail.com'));
        expect(newUser.phone, equals('+92 300 1234567'));
        expect(newUser.address, equals('House 14, Street 5, PECHS, Karachi'));
        expect(newUser.role, equals('user'));

        final userMap = newUser.toMap();
        expect(userMap['email'], equals('ali.laptop@gmail.com'));
        expect(userMap['name'], equals('Muhammad Ali'));
        expect(userMap['role'], equals('user'));

        final restoredUser = UserModel.fromMap(newUser.userId, userMap);
        expect(restoredUser.email, equals(newUser.email));
        expect(restoredUser.name, equals(newUser.name));
        expect(restoredUser.userId, equals(newUser.userId));
      });
    });

    group('2. Invalid Login: Error message show ho', () {
      test(
          'Input validators reject invalid credentials with descriptive error messages',
          () {
        expect(AppValidators.validateEmail(''),
            equals('Email address is required'));
        expect(AppValidators.validateEmail(null),
            equals('Email address is required'));
        expect(AppValidators.validateEmail('invalid_email_format'),
            equals('Please enter a valid email (e.g. name@domain.com)'));
        expect(AppValidators.validateEmail('user@nomail'),
            equals('Please enter a valid email (e.g. name@domain.com)'));

        expect(
            AppValidators.validatePassword(''), equals('Password is required'));
        expect(AppValidators.validatePassword(null),
            equals('Password is required'));
        expect(AppValidators.validatePassword('123'),
            equals('Password must be at least 6 characters'));
        expect(AppValidators.validatePassword('12345'),
            equals('Password must be at least 6 characters'));
      });

      test(
          'AppValidators maps invalid login and security error codes to user-friendly error messages',
          () {
        expect(AppValidators.mapAuthError('invalid-credential'),
            contains('Login failed'));
        expect(AppValidators.mapAuthError('wrong-password'),
            contains('Login failed'));
        expect(AppValidators.mapAuthError('user-not-found'),
            contains('No user found'));
        expect(AppValidators.mapAuthError('network-request-failed'),
            contains('Internet unavailable'));
        expect(AppValidators.mapAuthError('weak-password'),
            contains('Password too short'));
      });
    });

    group('3. Add Product to Cart: Cart mein product aaye', () {
      test('Product is successfully added to cart and total updates', () {
        final product = provider.products.first;

        expect(provider.cartCount, equals(0));
        expect(provider.cartItems, isEmpty);

        final added = provider.addToCart(product.id, 1);
        expect(added, isTrue);

        expect(provider.cartCount, equals(1));
        expect(provider.cartItems.length, equals(1));
        expect(provider.cartItems.first.product.id, equals(product.id));
        expect(provider.cartItems.first.quantity, equals(1));
        expect(provider.cartSubtotal, equals(product.price));
        expect(provider.cartTotal, equals(product.price + 500.0 + 2000.0));
      });

      test('Increasing quantity adds further units to the cart item', () {
        final product = provider.products.first;
        provider.addToCart(product.id, 1);
        provider.increaseQuantity(product.id);

        expect(provider.cartCount, equals(2));
        expect(provider.cartItems.first.quantity, equals(2));
        expect(provider.cartSubtotal, equals(product.price * 2));
      });
    });

    group('4. Remove Product: Cart se remove ho', () {
      test('removeFromCart completely removes item from cart', () {
        final p1 = provider.products[0];
        final p2 = provider.products[1];

        provider.addToCart(p1.id, 2);
        provider.addToCart(p2.id, 1);
        expect(provider.cartItems.length, equals(2));

        provider.removeFromCart(p1.id);

        expect(provider.cartItems.length, equals(1));
        expect(provider.cartItems.first.product.id, equals(p2.id));
        expect(provider.cartCount, equals(1));
      });

      test(
          'decreaseQuantity removes product from cart when quantity drops to zero',
          () {
        final p = provider.products.first;
        provider.addToCart(p.id, 1);
        expect(provider.cartCount, equals(1));

        provider.decreaseQuantity(p.id);

        expect(provider.cartCount, equals(0));
        expect(provider.cartItems, isEmpty);
        expect(provider.cartSubtotal, equals(0.0));
      });
    });

    group('5. Search Laptop: Correct products show hon', () {
      test('Searching "HP EliteBook" returns HP EliteBook laptops', () {
        final results = provider.filterProducts(searchQuery: 'HP EliteBook');
        expect(results.isNotEmpty, isTrue);
        for (final product in results) {
          expect(
            product.name.toLowerCase().contains('hp') ||
                product.brand.toLowerCase().contains('hp'),
            isTrue,
          );
          expect(product.name.toLowerCase().contains('elitebook'), isTrue);
        }
      });

      test('Searching "Dell Latitude" returns Dell Latitude laptops', () {
        final results = provider.filterProducts(searchQuery: 'Dell Latitude');
        expect(results.isNotEmpty, isTrue);
        for (final product in results) {
          expect(
            product.name.toLowerCase().contains('dell') ||
                product.brand.toLowerCase().contains('dell'),
            isTrue,
          );
          expect(product.name.toLowerCase().contains('latitude'), isTrue);
        }
      });

      test('Searching "MacBook" returns Apple MacBook models', () {
        final results = provider.filterProducts(searchQuery: 'MacBook');
        expect(results.isNotEmpty, isTrue);
        for (final product in results) {
          expect(product.name.toLowerCase().contains('macbook'), isTrue);
        }
      });

      test('Searching "ThinkPad" returns Lenovo ThinkPad models', () {
        final results = provider.filterProducts(searchQuery: 'ThinkPad');
        expect(results.isNotEmpty, isTrue);
        for (final product in results) {
          expect(product.name.toLowerCase().contains('thinkpad'), isTrue);
        }
      });
    });

    group('6. Wishlist: Product save ho', () {
      test('Toggling wishlist saves product and increments wishlist count', () {
        final product = provider.products.first;

        expect(provider.isInWishlist(product.id), isFalse);
        expect(provider.wishlistCount, equals(0));

        provider.toggleWishlist(product.id);

        expect(provider.isInWishlist(product.id), isTrue);
        expect(provider.wishlistCount, equals(1));
        expect(
            provider.wishlistProducts.any((p) => p.id == product.id), isTrue);
      });

      test('Toggling again removes product from saved wishlist', () {
        final product = provider.products.first;
        provider.toggleWishlist(product.id);
        expect(provider.isInWishlist(product.id), isTrue);

        provider.toggleWishlist(product.id);

        expect(provider.isInWishlist(product.id), isFalse);
        expect(provider.wishlistCount, equals(0));
      });
    });

    group('7. Checkout: Order generate ho', () {
      test('Checkout generates a valid order and clears user cart', () async {
        final product = provider.products.first;
        provider.addToCart(product.id, 1);
        expect(provider.cartCount, equals(1));

        final order = await provider.placeOrder(
          fullName: 'Muhammad Ali',
          phone: '03001234567',
          address: 'House 14, Block 6, PECHS',
          city: 'Karachi',
          postalCode: '75400',
          paymentMethod: 'Cash on Delivery',
        );

        expect(order.id.isNotEmpty, isTrue);
        expect(order.fullName, equals('Muhammad Ali'));
        expect(order.phone, equals('03001234567'));
        expect(order.address, equals('House 14, Block 6, PECHS'));
        expect(order.city, equals('Karachi'));
        expect(order.paymentMethod, equals('Cash on Delivery'));
        expect(order.status, equals('Pending'));
        expect(order.items.isNotEmpty, isTrue);
        expect(
            order.total, equals(order.subtotal + order.shipping + order.tax));

        expect(provider.cartCount, equals(0));
        expect(provider.cartItems, isEmpty);

        expect(provider.orders.any((o) => o.id == order.id), isTrue);
      });
    });

    group('8. Order Status: Updated status show ho', () {
      test('Order status updates across full delivery lifecycle', () async {
        final product = provider.products.first;
        provider.addToCart(product.id, 1);
        final order = await provider.placeOrder(
          fullName: 'Sara Ahmed',
          phone: '03121234567',
          address: 'Apartment 4B, Clifton',
          city: 'Karachi',
          postalCode: '75600',
          paymentMethod: 'Debit/Credit Card',
        );

        expect(order.status, equals('Pending'));

        final statuses = [
          'Confirmed',
          'Processing',
          'Shipped',
          'Out for Delivery',
          'Delivered',
        ];

        for (final status in statuses) {
          provider.updateOrderStatus(order.id, status);
          final updated = provider.getOrderById(order.id);
          expect(updated, isNotNull);
          expect(updated!.status, equals(status));
        }
      });

      test('Order status can be updated to Cancelled', () async {
        final product = provider.products.first;
        provider.addToCart(product.id, 1);
        final order = await provider.placeOrder(
          fullName: 'Hassan Raza',
          phone: '03331234567',
          address: 'Gulberg 3',
          city: 'Lahore',
          postalCode: '54000',
          paymentMethod: 'JazzCash',
        );

        provider.cancelOrder(order.id);
        final updated = provider.getOrderById(order.id);
        expect(updated?.status, equals('Cancelled'));
      });
    });

    group('9. Review: Product par review show ho', () {
      test(
          'Submitting a review shows on product and recalculates rating & review count',
          () async {
        final product = provider.products.first;
        final initialReviewCount = product.reviewsCount;

        final newReview = await provider.submitReview(
          productId: product.id,
          rating: 5.0,
          comment:
              'Very good laptop. Performance and battery timing is excellent.',
          userName: 'Muhammad Ali',
        );

        expect(newReview.rating, equals(5.0));
        expect(
            newReview.comment,
            equals(
                'Very good laptop. Performance and battery timing is excellent.'));
        expect(newReview.userName, equals('Muhammad Ali'));

        final reviews = provider.getReviews(product.id);
        expect(reviews.any((r) => r.id == newReview.id), isTrue);
        expect(
            reviews.first.comment,
            equals(
                'Very good laptop. Performance and battery timing is excellent.'));

        final updatedProduct = provider.getProductById(product.id);
        expect(updatedProduct, isNotNull);
        expect(updatedProduct!.reviewsCount, equals(initialReviewCount + 1));
      });
    });
  });
}
