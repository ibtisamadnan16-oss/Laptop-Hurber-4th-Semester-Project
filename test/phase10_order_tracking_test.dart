import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/order_model.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/screens/orders/order_details_screen.dart';
import 'package:e_project/screens/profile/orderScreen.dart';

void main() {
  group('Phase 10 — Order Tracking Unit Tests', () {
    test(
        'Order #LH1002 with status Shipped has 4 completed and 2 pending steps',
        () {
      final order = OrderModel(
        id: '1002',
        userId: 'usr_test',
        fullName: 'Muhammad Ali',
        phone: '0300 1234567',
        address: 'House 14, Block 6, PECHS',
        city: 'Karachi',
        postalCode: '75400',
        paymentMethod: 'Cash on Delivery',
        items: [
          {
            'name': 'HP EliteBook 840 G8',
            'quantity': 1,
            'price': 95000.0,
          }
        ],
        subtotal: 95000.0,
        shipping: 500.0,
        tax: 2000.0,
        total: 97500.0,
        createdAt: DateTime.now(),
        status: 'Shipped',
      );

      expect(order.displayTrackingId, equals('LH1002'));
      expect(order.currentStepIndex, equals(3));

      expect(order.formattedStep(0), equals('✓ Order Placed'));
      expect(order.formattedStep(1), equals('✓ Confirmed'));
      expect(order.formattedStep(2), equals('✓ Processing'));
      expect(order.formattedStep(3), equals('✓ Shipped'));
      expect(order.formattedStep(4), equals('○ Out for Delivery'));
      expect(order.formattedStep(5), equals('○ Delivered'));

      expect(order.stepSymbol(0), equals('✓'));
      expect(order.stepSymbol(1), equals('✓'));
      expect(order.stepSymbol(2), equals('✓'));
      expect(order.stepSymbol(3), equals('✓'));
      expect(order.stepSymbol(4), equals('○'));
      expect(order.stepSymbol(5), equals('○'));
    });

    test(
        'Provider seeds the requested Phase 10 demo orders: #1001, #1002, #1003',
        () {
      final provider = ProductProvider();
      expect(provider.orders.length, greaterThanOrEqualTo(3));

      final o1001 = provider.getOrderById('1001');
      final o1002 = provider.getOrderById('1002');
      final o1003 = provider.getOrderById('1003');

      expect(o1001, isNotNull);
      expect(o1001!.status, equals('Delivered'));

      expect(o1002, isNotNull);
      expect(o1002!.status, equals('Shipped'));

      expect(o1003, isNotNull);
      expect(o1003!.status, equals('Processing'));

      expect(provider.getOrderById('LH1002'), isNotNull);
      expect(provider.getOrderById('LH1002')!.id, equals('1002'));
    });
  });

  group('Phase 10 — Order Tracking UI Tests', () {
    testWidgets(
        'OrderDetailsScreen matches Order #LH1002 tracking progression exactly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final orderLH1002 = OrderModel(
        id: '1002',
        userId: 'demo_user',
        fullName: 'Muhammad Ali',
        phone: '0300 1234567',
        address: 'House 14, Block 6, PECHS',
        city: 'Karachi',
        postalCode: '75400',
        paymentMethod: 'Cash on Delivery',
        items: [
          {
            'productId': 'p1',
            'name': 'HP EliteBook 840 G8',
            'price': 95000.0,
            'quantity': 1,
          }
        ],
        subtotal: 95000.0,
        shipping: 500.0,
        tax: 2000.0,
        total: 97500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Shipped',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: orderLH1002),
        ),
      );
      await tester.pump();

      expect(find.text('Order #LH1002'), findsOneWidget);

      expect(find.text('Delivery Tracking'), findsOneWidget);

      expect(find.text('✓ Order Placed'), findsOneWidget);
      expect(find.text('✓ Confirmed'), findsOneWidget);
      expect(find.text('✓ Processing'), findsOneWidget);
      expect(find.text('✓ Shipped'), findsOneWidget);
      expect(find.text('○ Out for Delivery'), findsOneWidget);
      expect(find.text('○ Delivered'), findsOneWidget);

      expect(find.text('HP EliteBook 840 G8'), findsOneWidget);
      expect(find.text('Rs. 97,500'), findsOneWidget);
    });

    testWidgets(
        'OrdersScreen displays My Orders with #1001 Delivered, #1002 Shipped, #1003 Processing',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: OrdersScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('📦 My Orders'), findsOneWidget);

      expect(find.text('Order #1001'), findsOneWidget);
      expect(find.text('Delivered'), findsAtLeastNWidgets(1));

      expect(find.text('Order #1002'), findsOneWidget);
      expect(find.text('Shipped'), findsAtLeastNWidgets(1));

      expect(find.text('Order #1003'), findsOneWidget);
      expect(find.text('Processing'), findsAtLeastNWidgets(1));

      expect(find.text('View Tracking'), findsAtLeastNWidgets(3));
    });
  });
}
