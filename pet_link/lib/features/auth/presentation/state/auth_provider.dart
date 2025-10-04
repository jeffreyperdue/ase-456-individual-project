import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import 'package:petfolio/features/auth/data/auth_service.dart';

/// Provider for the AuthService.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for the current Firebase user.
final firebaseUserProvider = StreamProvider<firebase_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for the current app user (from Firestore).
final currentUserProvider = FutureProvider<app_user.User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentAppUser();
});

/// Notifier for authentication state management.
class AuthNotifier extends StateNotifier<AsyncValue<app_user.User?>> {
  AuthNotifier(this._authService, this._ref)
    : super(const AsyncValue.loading()) {
    _initialize();
  }

  final AuthService _authService;
  final Ref _ref;
  late StreamSubscription<firebase_auth.User?> _authSubscription;

  void _initialize() {
    // Listen to Firebase auth state changes
    _authSubscription = _authService.authStateChanges.listen(
      (firebaseUser) async {
        if (firebaseUser == null) {
          state = const AsyncValue.data(null);
          // Clear all user-specific data when signed out
          _clearUserData();
        } else {
          try {
            final appUser = await _authService.getCurrentAppUser();
            state = AsyncValue.data(appUser);
          } catch (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          }
        }
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  /// Sign up with email and password.
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Clear all user-specific provider data.
  void _clearUserData() {
    try {
      // Import the providers we need to invalidate
      _ref.invalidate(currentUserDataProvider);

      // Note: We can't directly import pet/care plan providers here due to circular imports
      // The UI layer will handle invalidating those providers
    } catch (e) {
      // Silently handle any errors during cleanup
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
      _clearUserData();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update user profile.
  Future<void> updateProfile(app_user.User user) async {
    try {
      await _authService.updateUserProfile(user);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

/// Provider for the AuthNotifier.
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return AuthNotifier(authService, ref);
    });

/// Convenience provider to get the current user data (non-nullable when authenticated).
final currentUserDataProvider = Provider<app_user.User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserDataProvider);
  return user != null;
});
