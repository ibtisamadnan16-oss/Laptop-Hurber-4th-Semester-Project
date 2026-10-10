import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal() {
    _initInitialNotifications();
  }

  final List<AppNotificationModel> _notifications = [];
  String? _fcmToken;
  bool _isInitialized = false;

  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String? get fcmToken => _fcmToken;

  void _initInitialNotifications() {
    final now = DateTime.now();

    _notifications.addAll([
      AppNotificationModel.forOrderStatus(
        id: 'notif_1002_delivered',
        orderId: '1002',
        status: 'Delivered',
        createdAt: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      AppNotificationModel.forOrderStatus(
        id: 'notif_1002_out_for_delivery',
        orderId: '1002',
        status: 'Out for Delivery',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      AppNotificationModel.forOrderStatus(
        id: 'notif_1002_shipped',
        orderId: '1002',
        status: 'Shipped',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotificationModel.forOrderStatus(
        id: 'notif_1001_delivered',
        orderId: '1001',
        status: 'Delivered',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
      AppNotificationModel.forOrderStatus(
        id: 'notif_1003_processing',
        orderId: '1003',
        status: 'Processing',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ]);
  }

  Future<void> initializeFCM() async {
    if (_isInitialized) return;

    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _fcmToken = await messaging.getToken();
        if (kDebugMode) {
          print('🔔 FCM Token: $_fcmToken');
        }
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleIncomingRemoteMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleIncomingRemoteMessage(message);
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('FCM initialization fallback: $e');
      }
    }
  }

  void _handleIncomingRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final orderId = message.data['orderId']?.toString();
    final status = message.data['status']?.toString();

    final newNotif = AppNotificationModel(
      id: message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      title: notification?.title ??
          (status != null
              ? AppNotificationModel.getOrderStatusTitle(status)
              : 'Order Update'),
      body: notification?.body ??
          (orderId != null && status != null
              ? AppNotificationModel.getOrderStatusBody(orderId, status)
              : 'You have a new update.'),
      orderId: orderId,
      status: status,
      createdAt: DateTime.now(),
      isRead: false,
      data: message.data,
    );

    addNotification(newNotif);
  }

  Future<AppNotificationModel> sendOrderStatusNotification({
    required String orderId,
    required String status,
  }) async {
    final notif = AppNotificationModel.forOrderStatus(
      orderId: orderId,
      status: status,
    );

    addNotification(notif);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notif.id)
            .set(notif.toMap());
      }
    } catch (_) {}

    return notif;
  }

  void addNotification(AppNotificationModel notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      _syncReadStatusToFirestore(id, true);
    }
  }

  void markAllAsRead() {
    bool hasUnread = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .delete();
      }
    } catch (_) {}
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void _syncReadStatusToFirestore(String id, bool isRead) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .update({'isRead': isRead});
      }
    } catch (_) {}
  }

  void resetToDemoData() {
    _notifications.clear();
    _initInitialNotifications();
    notifyListeners();
  }
}
