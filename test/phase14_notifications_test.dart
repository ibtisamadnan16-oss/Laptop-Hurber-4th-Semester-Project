import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/notification_model.dart';
import 'package:e_project/services/notification_service.dart';
import 'package:e_project/screens/notifications/notification_screen.dart';

void main() {
  group('Phase 14 — Notification Model Unit Tests', () {
    test('Formats exact user-specified order status notification bodies', () {
      final shippedBody =
          AppNotificationModel.getOrderStatusBody('1002', 'Shipped');
      expect(shippedBody, equals('Your Order #1002 has been shipped.'));

      final outForDeliveryBody =
          AppNotificationModel.getOrderStatusBody('1002', 'Out for Delivery');
      expect(
          outForDeliveryBody, equals('Your Order #1002 is out for delivery.'));

      final deliveredBody =
          AppNotificationModel.getOrderStatusBody('1002', 'Delivered');
      expect(deliveredBody, equals('Your Order #1002 has been delivered.'));

      final confirmedBody =
          AppNotificationModel.getOrderStatusBody('1001', 'Confirmed');
      expect(confirmedBody, equals('Your Order #1001 has been confirmed.'));

      final processingBody =
          AppNotificationModel.getOrderStatusBody('1003', 'Processing');
      expect(processingBody,
          equals('Your Order #1003 is currently being processed.'));
    });

    test('AppNotificationModel serialization and factory tests', () {
      final notif = AppNotificationModel.forOrderStatus(
        id: 'test_notif_1',
        orderId: '1002',
        status: 'Shipped',
        isRead: false,
      );

      expect(notif.id, equals('test_notif_1'));
      expect(notif.orderId, equals('1002'));
      expect(notif.status, equals('Shipped'));
      expect(notif.title, equals('Order Shipped'));
      expect(notif.body, equals('Your Order #1002 has been shipped.'));
      expect(notif.isRead, isFalse);

      final map = notif.toMap();
      expect(map['body'], equals('Your Order #1002 has been shipped.'));
      expect(map['orderId'], equals('1002'));

      final parsed = AppNotificationModel.fromMap(map, 'test_notif_1');
      expect(parsed.body, equals(notif.body));
      expect(parsed.orderId, equals('1002'));
      expect(parsed.status, equals('Shipped'));
    });
  });

  group('Phase 14 — NotificationService Business Logic Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
      service.resetToDemoData();
    });

    test('Service initializes with sample order status updates including #1002',
        () {
      final notifs = service.notifications;
      expect(notifs.isNotEmpty, isTrue);

      final bodies = notifs.map((n) => n.body).toList();
      expect(bodies, contains('Your Order #1002 has been delivered.'));
      expect(bodies, contains('Your Order #1002 is out for delivery.'));
      expect(bodies, contains('Your Order #1002 has been shipped.'));
    });

    test('Send order status notification inserts new notification at top',
        () async {
      final initialCount = service.notifications.length;

      final newNotif = await service.sendOrderStatusNotification(
        orderId: '1005',
        status: 'Shipped',
      );

      expect(newNotif.body, equals('Your Order #1005 has been shipped.'));
      expect(service.notifications.length, equals(initialCount + 1));
      expect(service.notifications.first.body,
          equals('Your Order #1005 has been shipped.'));
    });

    test('markAsRead updates item state and reduces unread count', () {
      final unreadBefore = service.unreadCount;
      expect(unreadBefore, greaterThan(0));

      final unreadItem = service.notifications.firstWhere((n) => !n.isRead);
      service.markAsRead(unreadItem.id);

      final updatedItem =
          service.notifications.firstWhere((n) => n.id == unreadItem.id);
      expect(updatedItem.isRead, isTrue);
      expect(service.unreadCount, equals(unreadBefore - 1));
    });

    test('markAllAsRead clears unread counter', () {
      service.markAllAsRead();
      expect(service.unreadCount, equals(0));
    });

    test('deleteNotification removes notification item', () {
      final itemToDelete = service.notifications.first;
      final initialCount = service.notifications.length;

      service.deleteNotification(itemToDelete.id);
      expect(service.notifications.length, equals(initialCount - 1));
      expect(
          service.notifications.any((n) => n.id == itemToDelete.id), isFalse);
    });
  });

  group('Phase 14 — NotificationScreen Widget UI Tests', () {
    setUp(() {
      NotificationService().resetToDemoData();
    });

    testWidgets(
        'Renders screen header, filter chips and order status notifications',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);

      expect(find.textContaining('All'), findsOneWidget);
      expect(find.textContaining('Orders'), findsOneWidget);
      expect(find.textContaining('Unread'), findsOneWidget);

      expect(find.text('Your Order #1002 has been delivered.'), findsOneWidget);
      expect(
          find.text('Your Order #1002 is out for delivery.'), findsOneWidget);
      expect(find.text('Your Order #1002 has been shipped.'), findsOneWidget);

      expect(find.text('#1002'), findsWidgets);
    });

    testWidgets('Tapping notification card marks it as read', (tester) async {
      final service = NotificationService();
      final initialUnread = service.unreadCount;

      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Your Order #1002 has been delivered.'));
      await tester.pumpAndSettle();

      expect(service.unreadCount, lessThan(initialUnread));
    });

    testWidgets('Filter by Unread shows only unread notifications',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Unread'));
      await tester.pumpAndSettle();

      expect(find.text('Your Order #1002 has been delivered.'), findsOneWidget);
      expect(
          find.text('Your Order #1002 is out for delivery.'), findsOneWidget);
    });

    testWidgets(
        'Opens simulation modal and dispatches test order status update',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simulate Update'));
      await tester.pumpAndSettle();

      expect(find.text('Simulate Order Notification'), findsOneWidget);
      expect(find.text('Notification Payload Preview:'), findsOneWidget);
      expect(find.text('Send Notification'), findsOneWidget);

      await tester.tap(find.text('Send Notification'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Notification sent:'), findsOneWidget);
    });
  });
}
