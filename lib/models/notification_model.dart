import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String? orderId;
  final String type;
  final String? status;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.orderId,
    this.type = 'order_status',
    this.status,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory AppNotificationModel.forOrderStatus({
    required String orderId,
    required String status,
    String? id,
    DateTime? createdAt,
    bool isRead = false,
  }) {
    final title = getOrderStatusTitle(status);
    final body = getOrderStatusBody(orderId, status);
    final finalId = id ??
        'notif_${orderId}_${status.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

    return AppNotificationModel(
      id: finalId,
      title: title,
      body: body,
      orderId: orderId,
      type: 'order_status',
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      isRead: isRead,
      data: {
        'orderId': orderId,
        'status': status,
      },
    );
  }

  static String getOrderStatusBody(String orderId, String status) {
    final cleanId = orderId.startsWith('#') ? orderId.substring(1) : orderId;

    switch (status.trim().toLowerCase()) {
      case 'shipped':
        return 'Your Order #$cleanId has been shipped.';
      case 'out for delivery':
        return 'Your Order #$cleanId is out for delivery.';
      case 'delivered':
        return 'Your Order #$cleanId has been delivered.';
      case 'confirmed':
        return 'Your Order #$cleanId has been confirmed.';
      case 'processing':
        return 'Your Order #$cleanId is currently being processed.';
      case 'cancelled':
        return 'Your Order #$cleanId has been cancelled.';
      case 'pending':
      case 'order placed':
        return 'Your Order #$cleanId has been placed successfully.';
      default:
        return 'Your Order #$cleanId status has been updated to $status.';
    }
  }

  static String getOrderStatusTitle(String status) {
    switch (status.trim().toLowerCase()) {
      case 'shipped':
        return 'Order Shipped';
      case 'out for delivery':
        return 'Order Out for Delivery';
      case 'delivered':
        return 'Order Delivered';
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Order Processing';
      case 'cancelled':
        return 'Order Cancelled';
      case 'pending':
      case 'order placed':
        return 'Order Placed';
      default:
        return 'Order Update';
    }
  }

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? orderId,
    String? type,
    String? status,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'orderId': orderId,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map,
      [String? docId]) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return AppNotificationModel(
      id: docId ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      orderId: map['orderId']?.toString(),
      type: map['type']?.toString() ?? 'order_status',
      status: map['status']?.toString(),
      createdAt: parseDate(map['createdAt']),
      isRead: map['isRead'] == true,
      data: map['data'] is Map ? Map<String, dynamic>.from(map['data']) : null,
    );
  }
}
