import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String uid;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final int helpful;

  ReviewModel({
    required this.id,
    required this.uid,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.helpful,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> m) {
    return ReviewModel(
      id: id,
      uid: m['uid'] ?? '',
      rating: (m['rating'] ?? 0) as int,
      comment: (m['comment'] ?? '') as String,
      createdAt: (m['createdAt'] is Timestamp)
          ? (m['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      helpful: (m['helpful'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "rating": rating,
      "comment": comment,
      "createdAt": Timestamp.fromDate(createdAt),
      "helpful": helpful,
    };
  }
}
