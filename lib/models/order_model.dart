import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class OrderModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final DateTime createdAt;
  final String status;

  static const List<String> allStatuses = [
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  static const List<String> validStatuses = allStatuses;

  static const List<String> trackingSteps = [
    'Order Placed',
    'Confirmed',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
  ];

  const OrderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.createdAt,
    this.status = 'Pending',
  });

  String get orderId => id;
  List<Map<String, dynamic>> get products => items;
  DateTime get orderDate => createdAt;
  String get shippingAddress => '$address, $city, $postalCode';

  String get displayTrackingId {
    if (id.startsWith('LH')) return id;
    return 'LH$id';
  }

  String get formattedTotal {
    final str = total.round().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return 'Rs. ${buffer.toString().split('').reversed.join('')}';
  }

  int get currentStepIndex {
    if (status == 'Cancelled') return -1;
    switch (status) {
      case 'Pending':
      case 'Order Placed':
        return 0;
      case 'Confirmed':
        return 1;
      case 'Processing':
        return 2;
      case 'Shipped':
        return 3;
      case 'Out for Delivery':
        return 4;
      case 'Delivered':
        return 5;
      default:
        final idx = trackingSteps.indexOf(status);
        return idx >= 0 ? idx : 0;
    }
  }

  bool isStepCompleted(int index) =>
      currentStepIndex >= 0 && index <= currentStepIndex;

  String stepSymbol(int index) => isStepCompleted(index) ? '✓' : '○';

  String formattedStep(int index) {
    if (index < 0 || index >= trackingSteps.length) return '';
    return '${stepSymbol(index)} ${trackingSteps[index]}';
  }

  Color get statusColor {
    switch (status) {
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      case 'Out for Delivery':
        return const Color(0xFFFF7675);
      case 'Shipped':
        return const Color(0xFF74B9FF);
      case 'Processing':
        return const Color(0xFFA29BFE);
      case 'Confirmed':
        return const Color(0xFF00CEC9);
      case 'Pending':
      default:
        return AppColors.warning;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle_outline_rounded;
      case 'Cancelled':
        return Icons.cancel_outlined;
      case 'Out for Delivery':
        return Icons.delivery_dining_rounded;
      case 'Shipped':
        return Icons.local_shipping_outlined;
      case 'Processing':
        return Icons.precision_manufacturing_outlined;
      case 'Confirmed':
        return Icons.verified_outlined;
      case 'Pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? paymentMethod,
    List<Map<String, dynamic>>? items,
    double? subtotal,
    double? shipping,
    double? tax,
    double? total,
    DateTime? createdAt,
    String? status,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': id,
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'items': items,
      'products': items,
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'orderDate': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawDate = map['createdAt'] ?? map['orderDate'];
    DateTime parsedDate;
    if (rawDate != null) {
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    final rawItems = map['items'] ?? map['products'] ?? [];

    return OrderModel(
      id: docId ?? map['id'] ?? map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? map['shippingAddress'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Cash on Delivery',
      items: List<Map<String, dynamic>>.from(rawItems),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (map['shipping'] as num?)?.toDouble() ?? 500.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 2000.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedDate,
      status: map['status'] ?? 'Pending',
    );
  }
}
