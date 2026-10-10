import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/utils/validators.dart';
import 'package:e_project/services/network_service.dart';
import 'package:e_project/services/auth_service.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/models/product_model.dart';
import 'package:e_project/models/user_model.dart';
import 'package:e_project/widgets/offline_banner.dart';
import 'package:e_project/screens/checkout/checkout_screen.dart';
import 'package:e_project/screens/products/product_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 16 — Validation Unit Tests', () {
    test(
        'Email Validation: rejects invalid email formats and accepts valid ones',
        () {
      expect(AppValidators.validateEmail(null),
          equals('Email address is required'));
      expect(
          AppValidators.validateEmail(''), equals('Email address is required'));
      expect(AppValidators.validateEmail('   '),
          equals('Email address is required'));
      expect(
          AppValidators.validateEmail('invalidemail'), contains('valid email'));
      expect(AppValidators.validateEmail('user@'), contains('valid email'));
      expect(
          AppValidators.validateEmail('@domain.com'), contains('valid email'));
      expect(
          AppValidators.validateEmail('user@domain'), contains('valid email'));

      expect(AppValidators.validateEmail('user@domain.com'), isNull);
      expect(AppValidators.validateEmail('admin@laptopharbor.com'), isNull);
      expect(AppValidators.validateEmail('customer.service@sub.example.pk'),
          isNull);
    });

    test('Password Validation: rejects short passwords (< 6 chars)', () {
      expect(
          AppValidators.validatePassword(null), equals('Password is required'));
      expect(
          AppValidators.validatePassword(''), equals('Password is required'));
      expect(AppValidators.validatePassword('123'),
          contains('at least 6 characters'));
      expect(AppValidators.validatePassword('abcde'),
          contains('at least 6 characters'));

      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('admin123'), isNull);
      expect(AppValidators.validatePassword('StrongPassword!2026'), isNull);
    });

    test('Product Availability: rejects 0 or negative stock', () {
      expect(AppValidators.validateProductAvailability(0),
          equals('Product unavailable (out of stock)'));
      expect(AppValidators.validateProductAvailability(-2),
          equals('Product unavailable (out of stock)'));
      expect(AppValidators.validateProductAvailability(1), isNull);
      expect(AppValidators.validateProductAvailability(15), isNull);
    });

    test('Cart Empty Validation: rejects checkout attempt when empty', () {
      expect(AppValidators.validateCartNotEmpty(0), contains('Cart is empty'));
      expect(AppValidators.validateCartNotEmpty(-1), contains('Cart is empty'));
      expect(AppValidators.validateCartNotEmpty(1), isNull);
      expect(AppValidators.validateCartNotEmpty(3), isNull);
    });

    test('Network Connectivity Validation: flags when internet is disconnected',
        () {
      expect(AppValidators.validateNetwork(false),
          contains('Internet unavailable'));
      expect(AppValidators.validateNetwork(true), isNull);
    });

    test('Auth Error Code Mapping: provides friendly descriptions', () {
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

  group('Phase 16 — NetworkService & OfflineBanner Tests', () {
    late NetworkService networkService;

    setUp(() {
      networkService = NetworkService();
      networkService.setSimulatedOffline(false);
    });

    tearDown(() {
      networkService.setSimulatedOffline(false);
    });

    test('NetworkService tracks online and simulated offline state', () {
      expect(networkService.isConnected, isTrue);

      networkService.setSimulatedOffline(true);
      expect(networkService.isConnected, isFalse);
      expect(networkService.isConnectedNotifier.value, isFalse);

      networkService.setSimulatedOffline(false);
      expect(networkService.isConnected, isTrue);
    });

    testWidgets(
        'OfflineBanner displays banner when disconnected and hides when online',
        (tester) async {
      networkService.setSimulatedOffline(false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                OfflineBanner(),
                Text('Main Content'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Internet unavailable. Operating in offline mode.'),
          findsNothing);

      networkService.setSimulatedOffline(true);
      await tester.pumpAndSettle();

      expect(find.text('Internet unavailable. Operating in offline mode.'),
          findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });
  });

  group('Phase 16 — Product Unavailable & Empty Cart Business Logic Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearCart();
    });

    test('ProductProvider rejects adding out-of-stock product to cart', () {
      final outOfStockLaptop = ProductModel(
        id: 'laptop_out_of_stock_test',
        name: 'HP Omen 16 (Sold Out)',
        brand: 'HP',
        category: 'Gaming',
        price: 320000,
        imageUrl:
            'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500',
        description: 'Sold out unit',
        stock: 0,
      );

      provider.addProduct(outOfStockLaptop);

      expect(provider.isProductAvailable('laptop_out_of_stock_test'), isFalse);

      final added = provider.addToCart('laptop_out_of_stock_test', 1);
      expect(added, isFalse);
      expect(provider.cartQuantity('laptop_out_of_stock_test'), equals(0));

      provider.deleteProduct('laptop_out_of_stock_test');
    });

    test('ProductProvider placeOrder throws exception when cart is empty',
        () async {
      provider.clearCart();
      expect(provider.cartItems.isEmpty, isTrue);

      expect(
        () => provider.placeOrder(
          fullName: 'Test User',
          phone: '+92 300 1234567',
          address: 'Karachi, Pakistan',
          city: 'Karachi',
          postalCode: '75000',
          paymentMethod: 'Cash on Delivery',
        ),
        throwsA(contains('Cart is empty')),
      );
    });

    testWidgets(
        'ProductDetailsScreen shows Product Unavailable banner when stock is 0',
        (tester) async {
      const outOfStockLaptop = ProductModel(
        id: 'laptop_oos_ui',
        name: 'Dell XPS 15 (Zero Stock)',
        brand: 'Dell',
        category: 'Business',
        price: 280000,
        imageUrl:
            'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500',
        description: 'Out of stock description',
        stock: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailsScreen(product: outOfStockLaptop),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Product Unavailable (Out of Stock)'),
          findsWidgets);

      expect(find.text('Add to Cart'), findsNothing);
    });

    testWidgets(
        'CheckoutScreen displays empty cart notice when cart has no items',
        (tester) async {
      provider.clearCart();

      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Return to Cart'), findsOneWidget);
    });
  });

  group('Phase 16 — Security Architecture & Firestore Security Rules Tests',
      () {
    test(
        'UserModel and serialized maps NEVER include plaintext passwords or hashes',
        () {
      final user = UserModel(
        userId: 'usr_sec_1',
        email: 'safe@laptopharbor.com',
        name: 'Safe User',
        phone: '+92 321 0000000',
        address: 'Secured Street, Karachi',
        role: 'user',
      );

      final map = user.toMap();
      expect(map.containsKey('password'), isFalse);
      expect(map.containsKey('hash'), isFalse);
      expect(map.containsKey('passwordHash'), isFalse);
      expect(map.containsKey('pwd'), isFalse);
    });

    test('AuthService isAdmin check properly isolates admin permissions',
        () async {
      final authService = AuthService();

      final isCustomerAdmin = await authService.isAdmin('usr_customer_999');
      expect(isCustomerAdmin, isFalse);
    });

    test(
        'firestore.rules file exists and implements all Phase 16 security constraints',
        () {
      final rulesFile = File('firestore.rules');
      expect(rulesFile.existsSync(), isTrue);

      final content = rulesFile.readAsStringSync();

      expect(content, contains("rules_version = '2'"));

      expect(content, contains('function isSignedIn()'));
      expect(content, contains('function isOwner(userId)'));
      expect(content, contains('function isAdmin()'));

      expect(content, contains('function noPasswordOrHash(data)'));
      expect(content, contains("!hasField(data, 'password')"));

      expect(content, contains('match /users/{userId}'));
      expect(content, contains('match /cart/{cartId}'));
      expect(content, contains('match /wishlist/{wishlistId}'));

      expect(content, contains('match /products/{productId}'));
      expect(content, contains('match /orders/{orderId}'));
      expect(content, contains('match /reviews/{productId}'));
      expect(content, contains('match /supportTickets/{ticketId}'));
    });
  });
}
