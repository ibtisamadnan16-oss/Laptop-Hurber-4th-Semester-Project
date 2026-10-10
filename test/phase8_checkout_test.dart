import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/screens/checkout/checkout_screen.dart';

void main() {
  group('Phase 8 — Checkout Business Logic Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearCart();
    });

    test('placeOrder creates valid OrderModel and clears cart', () async {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      expect(provider.cartCount, equals(1));
      expect(provider.cartTotal, equals(97500.0));

      final order = await provider.placeOrder(
        fullName: 'Muhammad Ali',
        phone: '03001234567',
        address: 'House 12, Street 4, Gulshan',
        city: 'Karachi',
        postalCode: '75300',
        paymentMethod: 'Cash on Delivery',
      );

      expect(order.id.startsWith('LH-'), isTrue);
      expect(order.fullName, equals('Muhammad Ali'));
      expect(order.phone, equals('03001234567'));
      expect(order.address, equals('House 12, Street 4, Gulshan'));
      expect(order.city, equals('Karachi'));
      expect(order.postalCode, equals('75300'));
      expect(order.paymentMethod, equals('Cash on Delivery'));
      expect(order.subtotal, equals(95000.0));
      expect(order.shipping, equals(500.0));
      expect(order.tax, equals(2000.0));
      expect(order.total, equals(97500.0));
      expect(order.formattedTotal, equals('Rs. 97,500'));
      expect(order.status, equals('Pending'));

      expect(provider.cartCount, equals(0));
      expect(provider.cartItems.isEmpty, isTrue);

      expect(provider.orders.isNotEmpty, isTrue);
      expect(provider.orders.first.id, equals(order.id));
    });

    test('Support all payment methods: COD, Card, JazzCash, EasyPaisa',
        () async {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));

      final methods = [
        'Cash on Delivery',
        'Debit/Credit Card',
        'JazzCash',
        'EasyPaisa',
      ];

      for (final method in methods) {
        provider.addToCart(hpLaptop.id, 1);
        final order = await provider.placeOrder(
          fullName: 'Test User',
          phone: '03123456789',
          address: 'Test Address',
          city: 'Lahore',
          postalCode: '54000',
          paymentMethod: method,
        );
        expect(order.paymentMethod, equals(method));
      }
    });
  });

  group('Phase 8 — CheckoutScreen UI & Form Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearCart();
    });

    testWidgets(
        'CheckoutScreen renders Shipping, Payment, and Summary sections',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Shipping Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Postal Code'), findsOneWidget);

      expect(find.text('Payment Information'), findsOneWidget);
      expect(find.textContaining('Cash on Delivery'), findsOneWidget);
      expect(find.textContaining('Debit / Credit Card'), findsOneWidget);
      expect(find.textContaining('JazzCash'), findsOneWidget);
      expect(find.text('EasyPaisa'), findsOneWidget);

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Subtotal:'), findsOneWidget);
      expect(find.text('Shipping:'), findsOneWidget);
      expect(find.text('Tax:'), findsOneWidget);
      expect(find.text('Total:'), findsOneWidget);
      expect(find.text('Rs. 97,500'), findsAtLeastNWidgets(1));

      expect(find.textContaining('Place Order'), findsOneWidget);
    });

    testWidgets('Place Order form validation and success submission',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Muhammad Ali');
      await tester.enterText(find.byType(TextFormField).at(1), '03001234567');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'Shahr-e-Faisal');
      await tester.enterText(find.byType(TextFormField).at(3), 'Karachi');
      await tester.enterText(find.byType(TextFormField).at(4), '75200');

      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      expect(find.textContaining('Place Order'), findsOneWidget);
      await tester.tap(find.textContaining('Place Order'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Order Placed Successfully'), findsOneWidget);
      expect(find.text('View My Orders'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      expect(provider.cartCount, equals(0));
    });
  });
}
