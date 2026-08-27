import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';

/// Authentication service for user sign up, sign in, and sign out
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  /// Sign in anonymously and create user document if not exists
  Future<UserModel?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final uid = userCredential.user?.uid;

      if (uid == null) {
        throw Exception('Failed to get user ID');
      }

      // Check if user document exists
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        // Create new user document
        final doorwayId = _firestore
            .collection(AppConstants.doorwaysCollection)
            .doc()
            .id;

        final newUser = UserModel(
          uid: uid,
          displayName: 'Player_$uid'.substring(0, 20), // Limit length
          doorwayId: doorwayId,
          streak: 0,
          ownedSkins: [],
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(newUser);

        return newUser;
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String uid, String displayName) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({AppConstants.displayNameField: displayName});
    } catch (e) {
      print('Error updating display name: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Increment user streak
  Future<void> incrementStreak(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        AppConstants.streakField: FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing streak: $e');
      rethrow;
    }
  }

  /// Add skin to user's owned skins
  Future<void> addOwnedSkin(String uid, String skinId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        AppConstants.ownedSkinsField: FieldValue.arrayUnion([skinId]),
      });
    } catch (e) {
      print('Error adding owned skin: $e');
      rethrow;
    }
  }
}
