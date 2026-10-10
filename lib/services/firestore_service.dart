import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firebase_collections.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> createSupportTicket(
    String subject,
    String message, {
    String? name,
    String? email,
    String? category,
  }) async {
    final uid = _uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection(Fc.supportTickets).add({
      'userId': uid,
      'uid': uid,
      'name': name ?? 'Customer',
      'email': email ?? '',
      'category': category ?? 'General Issue',
      'subject': subject.trim(),
      'message': message.trim(),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createReview(
    String productId,
    int rating,
    String comment,
  ) async {
    final uid = _uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection(Fc.reviews).doc(productId).collection('items').add({
      'userId': uid,
      'rating': rating.toDouble(),
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'helpfulCount': 0,
    });
  }
}
