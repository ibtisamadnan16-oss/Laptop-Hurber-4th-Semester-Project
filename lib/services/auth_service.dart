import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const String usersCollection = 'users';

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> authState() {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return Stream.value(null);
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    String? profileImage,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw 'Failed to create user account';
      }

      await user.updateDisplayName(name.trim());

      final String userId = user.uid;

      final Map<String, dynamic> userData = {
        'userId': userId,
        'uid': userId,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'address': address.trim(),
        'addresses': [address.trim()],
        'profileImage': profileImage ?? '',
        'photoUrl': profileImage ?? '',
        'role': 'user',
        'cart': [],
        'wishlist': [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .set(userData, SetOptions(merge: true));

      return UserModel.fromMap(userId, userData);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAdmin([String? uid]) async {
    try {
      final email = currentUser?.email?.toLowerCase();
      if (email == 'admin@laptopharbor.com') return true;

      final targetUid = uid ?? currentUser?.uid;
      if (targetUid == null) return false;

      final profile = await getUserProfile(targetUid);
      return profile?.role.toLowerCase() == 'admin';
    } catch (_) {
      return false;
    }
  }

  Stream<UserModel?> streamUserProfile(String userId) {
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name.trim();
    if (phone != null) updates['phone'] = phone.trim();
    if (address != null) {
      updates['address'] = address.trim();
      updates['addresses'] = [address.trim()];
    }
    if (profileImage != null) {
      updates['profileImage'] = profileImage;
      updates['photoUrl'] = profileImage;
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .set(updates, SetOptions(merge: true));

      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name.trim());
      }
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw 'No user is currently signed in.';
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in or reset your password.';
      case 'invalid-email':
        return 'The email address is formatted incorrectly.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please wait a few moments and try again.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
