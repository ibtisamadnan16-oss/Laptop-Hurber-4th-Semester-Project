class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int helpfulCount;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.helpfulCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'helpfulCount': helpfulCount,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate != null) {
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return ReviewModel(
      id: docId ?? map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? map['uid'] ?? 'guest_user',
      userName: map['userName'] ?? 'Customer',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment'] ?? '',
      createdAt: parsedDate,
      helpfulCount:
          (map['helpfulCount'] ?? map['helpful'] as num?)?.toInt() ?? 0,
    );
  }
}
