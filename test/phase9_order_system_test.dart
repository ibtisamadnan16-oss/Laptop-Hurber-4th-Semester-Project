import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/order_model.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/screens/orders/order_details_screen.dart';
import 'package:e_project/screens/profile/orderScreen.dart';

void main() {
  group('Phase 9 — Order Structure & Statuses Unit Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.clearOrders();
    });

    test('OrderModel contains all required Phase 9 fields', () {
      final now = DateTime.now();
      final order = OrderModel(
        id: 'LH-123456',
        userId: 'usr_789',
        fullName: 'Muhammad Ali',
        phone: '03001234567',
        address: 'House 5, Street 10',
        city: 'Karachi',
        postalCode: '75200',
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
        createdAt: now,
        status: 'Pending',
      );

      expect(order.orderId, equals('LH-123456'));
      expect(order.userId, equals('usr_789'));
      expect(order.products.length, equals(1));
      expect(order.total, equals(97500.0));
      expect(order.shippingAddress, contains('Karachi'));
      expect(order.paymentMethod, equals('Cash on Delivery'));
      expect(order.orderDate, equals(now));
      expect(order.status, equals('Pending'));
    });

    test('All 7 official Phase 9 statuses are supported and recognized', () {
      final statuses = [
        'Pending',
        'Confirmed',
        'Processing',
        'Shipped',
        'Out for Delivery',
        'Delivered',
        'Cancelled',
      ];

      for (final s in statuses) {
        expect(OrderModel.allStatuses.contains(s), isTrue);

        final order = OrderModel(
          id: 'LH-TEST-$s',
          userId: 'test',
          fullName: 'Test User',
          phone: '03000000000',
          address: 'Test',
          city: 'Test',
          postalCode: '00000',
          paymentMethod: 'Cash on Delivery',
          items: [],
          subtotal: 0,
          shipping: 0,
          tax: 0,
          total: 0,
          createdAt: DateTime.now(),
          status: s,
        );

        expect(order.status, equals(s));
        expect(order.statusColor, isNotNull);
        expect(order.statusIcon, isNotNull);
      }
    });

    test(
        'Order status transitions from Pending through Delivered and Cancelled',
        () async {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      provider.addToCart(hpLaptop.id, 1);

      final order = await provider.placeOrder(
        fullName: 'Muhammad Ali',
        phone: '03001234567',
        address: 'House 5, Street 10',
        city: 'Karachi',
        postalCode: '75200',
        paymentMethod: 'Cash on Delivery',
      );

      expect(order.status, equals('Pending'));

      provider.updateOrderStatus(order.id, 'Confirmed');
      expect(provider.getOrderById(order.id)?.status, equals('Confirmed'));

      provider.updateOrderStatus(order.id, 'Processing');
      expect(provider.getOrderById(order.id)?.status, equals('Processing'));

      provider.updateOrderStatus(order.id, 'Shipped');
      expect(provider.getOrderById(order.id)?.status, equals('Shipped'));

      provider.updateOrderStatus(order.id, 'Out for Delivery');
      expect(
          provider.getOrderById(order.id)?.status, equals('Out for Delivery'));

      provider.updateOrderStatus(order.id, 'Delivered');
      expect(provider.getOrderById(order.id)?.status, equals('Delivered'));

      provider.cancelOrder(order.id);
      expect(provider.getOrderById(order.id)?.status, equals('Cancelled'));
    });
  });

  group('Phase 9 — Order Tracking & Details Widget Tests', () {
    testWidgets(
        'OrderDetailsScreen displays tracking timeline and all order sections',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testOrder = OrderModel(
        id: 'LH-999999',
        userId: 'usr_test',
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
        createdAt: DateTime.now(),
        status: 'Shipped',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsScreen(order: testOrder),
        ),
      );
      await tester.pump();

      expect(find.text('Order #LH-999999'), findsOneWidget);

      expect(find.text('Status: Shipped'), findsOneWidget);

      expect(find.text('Delivery Tracking'), findsOneWidget);
      expect(find.text('✓ Order Placed'), findsOneWidget);
      expect(find.text('✓ Confirmed'), findsOneWidget);
      expect(find.text('✓ Processing'), findsOneWidget);
      expect(find.text('✓ Shipped'), findsOneWidget);
      expect(find.text('○ Out for Delivery'), findsOneWidget);
      expect(find.text('○ Delivered'), findsOneWidget);

      expect(find.text('Products Ordered'), findsOneWidget);
      expect(find.text('HP EliteBook 840 G8'), findsOneWidget);

      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Muhammad Ali'), findsOneWidget);
      expect(find.textContaining('PECHS'), findsOneWidget);

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Shipping'), findsOneWidget);
      expect(find.text('Tax'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Rs. 97,500'), findsOneWidget);
    });

    testWidgets('OrdersScreen displays filter tabs and order cards',
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

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Delivered'), findsAtLeastNWidgets(1));
      expect(find.text('Cancelled'), findsAtLeastNWidgets(1));
    });
  });
}
