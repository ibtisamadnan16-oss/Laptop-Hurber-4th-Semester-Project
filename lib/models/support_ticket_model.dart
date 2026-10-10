import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String id;
  final String name;
  final String email;
  final String category;
  final String subject;
  final String message;
  final String? userId;
  final String status;
  final DateTime createdAt;

  SupportTicketModel({
    required this.id,
    required this.name,
    required this.email,
    required this.category,
    required this.subject,
    required this.message,
    this.userId,
    this.status = 'Open',
    required this.createdAt,
  });

  static const List<String> categories = [
    'Order Issue',
    'Payment Issue',
    'Delivery Issue',
    'Product Issue',
    'Account Issue',
    'Other',
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userName': name,
      'email': email,
      'userEmail': email,
      'category': category,
      'subject': subject,
      'message': message,
      'userId': userId,
      'uid': userId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SupportTicketModel.fromMap(Map<String, dynamic> map,
      [String? docId]) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return SupportTicketModel(
      id: docId ?? map['id']?.toString() ?? map['ticketId']?.toString() ?? '',
      name: map['name']?.toString() ?? map['userName']?.toString() ?? '',
      email: map['email']?.toString() ?? map['userEmail']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
      subject: map['subject']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['uid']?.toString(),
      status: map['status']?.toString() ?? 'Open',
      createdAt: parseDate(map['createdAt']),
    );
  }
}
