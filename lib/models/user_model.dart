import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String profileImage;
  final String role;
  final List<dynamic> addresses;
  final List<dynamic> cart;
  final List<dynamic> wishlist;
  final DateTime? createdAt;

  String get uid => userId;
  String get photoUrl => profileImage;

  UserModel({
    required this.userId,
    required this.email,
    this.name = '',
    this.phone = '',
    this.address = '',
    this.profileImage = '',
    this.role = 'user',
    this.addresses = const [],
    this.cart = const [],
    this.wishlist = const [],
    this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic timestamp) {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) return DateTime.tryParse(timestamp);
      return null;
    }

    final rawAddress = map['address']?.toString() ?? '';
    final rawAddresses = List<dynamic>.from(map['addresses'] ?? []);
    final resolvedAddress = rawAddress.isNotEmpty
        ? rawAddress
        : (rawAddresses.isNotEmpty ? rawAddresses.first.toString() : '');

    return UserModel(
      userId: map['userId']?.toString() ?? map['uid']?.toString() ?? id,
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: resolvedAddress,
      profileImage:
          map['profileImage']?.toString() ?? map['photoUrl']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      addresses: rawAddresses.isNotEmpty
          ? rawAddresses
          : (resolvedAddress.isNotEmpty ? [resolvedAddress] : []),
      cart: List<dynamic>.from(map['cart'] ?? []),
      wishlist: List<dynamic>.from(map['wishlist'] ?? []),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'uid': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'addresses': addresses.isNotEmpty
          ? addresses
          : (address.isNotEmpty ? [address] : []),
      'profileImage': profileImage,
      'photoUrl': profileImage,
      'role': role,
      'cart': cart,
      'wishlist': wishlist,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
