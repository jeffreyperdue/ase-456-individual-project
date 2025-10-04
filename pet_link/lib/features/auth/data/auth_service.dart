import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;

/// Service for handling Firebase Authentication and user management.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the current user stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the current Firebase user.
  User? get currentUser => _auth.currentUser;

  /// Get the current app user from Firestore.
  Future<app_user.User?> getCurrentAppUser() async {
    final firebaseUser = currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return app_user.User.fromJson(doc.data()!);
      } else {
        // User doesn't exist in Firestore, create them
        return await _createUserInFirestore(firebaseUser);
      }
    } catch (e) {
      print('Error getting current app user: $e');
      return null;
    }
  }

  /// Sign up with email and password.
  Future<app_user.User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await firebaseUser.updateDisplayName(displayName);
        // Reload the user to get the updated displayName
        await firebaseUser.reload();
        final updatedUser = _auth.currentUser;
        if (updatedUser != null) {
          return await _createUserInFirestore(updatedUser);
        }
      }

      // Create user in Firestore
      return await _createUserInFirestore(firebaseUser);
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password.
  Future<app_user.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      return await getCurrentAppUser();
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected sign in error: $e');
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected password reset error: $e');
      rethrow;
    }
  }

  /// Create a user document in Firestore.
  Future<app_user.User> _createUserInFirestore(User firebaseUser) async {
    final appUser = app_user.User.fromFirebaseAuth(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );

    try {
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(appUser.toJson());
      print('✅ User created in Firestore: ${appUser.email}');
      return appUser;
    } catch (e) {
      print('❌ Error creating user in Firestore: $e');
      rethrow;
    }
  }

  /// Update user profile in Firestore.
  Future<void> updateUserProfile(app_user.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'roles': user.roles,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User profile updated: ${user.email}');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }
}
