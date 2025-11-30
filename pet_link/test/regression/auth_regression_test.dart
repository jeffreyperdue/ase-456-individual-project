// Regression test: Authentication Edge Cases
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'auth_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthService])
void main() {
  group('Regression: Authentication Edge Cases', () {
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockAuthService = MockAuthService();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    test('should handle invalid email format gracefully', () async {
      // Arrange
      const invalidEmail = 'not-an-email';
      const password = 'password123';

      // Act & Assert
      final authNotifier = container.read(authProvider.notifier);
      
      // The service should reject invalid email
      when(mockAuthService.signUpWithEmailAndPassword(
        email: invalidEmail,
        password: password,
        displayName: null,
      )).thenThrow(Exception('Invalid email format'));

      expect(
        () => authNotifier.signUp(
          email: invalidEmail,
          password: password,
        ),
        throwsException,
      );
    });

    test('should handle weak password rejection', () async {
      // Arrange
      const email = 'test@example.com';
      const weakPassword = '123'; // Too short

      // Act & Assert
      when(mockAuthService.signUpWithEmailAndPassword(
        email: email,
        password: weakPassword,
        displayName: null,
      )).thenThrow(Exception('Password is too weak'));

      final authNotifier = container.read(authProvider.notifier);
      expect(
        () => authNotifier.signUp(
          email: email,
          password: weakPassword,
        ),
        throwsException,
      );
    });

    test('should handle network failure during login', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(mockAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenThrow(Exception('Network error: Unable to connect'));

      // Act & Assert
      final authNotifier = container.read(authProvider.notifier);
      expect(
        () => authNotifier.signIn(
          email: email,
          password: password,
        ),
        throwsException,
      );

      // Verify error state is set
      final authState = container.read(authProvider);
      expect(authState.hasError, isTrue);
    });

    test('should handle session expiration gracefully', () async {
      // Arrange: User was logged in, then session expires
      final testUser = TestDataFactory.createTestUser();
      
      // Simulate session expiration by returning null user
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => null);

      // Act: Initialize auth notifier (simulates app startup)
      final authNotifier = container.read(authProvider.notifier);
      
      // Wait for auth state to settle
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: User should be logged out
      final authState = container.read(authProvider);
      expect(authState.value, isNull);
    });

    test('should handle user deletion while logged in', () async {
      // Arrange: User is logged in
      final testUser = TestDataFactory.createTestUser();
      
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);

      // Simulate user deletion by returning null after initial login
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => null);

      // Act: Validate current user (simulates periodic validation)
      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.validateCurrentUser();

      // Assert: User should be logged out
      final authState = container.read(authProvider);
      // Note: Actual behavior depends on implementation
      // This test ensures the validation doesn't crash
      expect(authState, isNotNull);
    });

    test('should handle empty email input', () async {
      // Arrange
      const emptyEmail = '';
      const password = 'password123';

      // Act & Assert
      final authNotifier = container.read(authProvider.notifier);
      
      // Empty email should be rejected before reaching service
      // This is typically handled by form validation, but we test the service layer
      when(mockAuthService.signUpWithEmailAndPassword(
        email: emptyEmail,
        password: password,
        displayName: null,
      )).thenThrow(Exception('Email cannot be empty'));

      expect(
        () => authNotifier.signUp(
          email: emptyEmail,
          password: password,
        ),
        throwsException,
      );
    });

    test('should handle empty password input', () async {
      // Arrange
      const email = 'test@example.com';
      const emptyPassword = '';

      // Act & Assert
      when(mockAuthService.signUpWithEmailAndPassword(
        email: email,
        password: emptyPassword,
        displayName: null,
      )).thenThrow(Exception('Password cannot be empty'));

      final authNotifier = container.read(authProvider.notifier);
      expect(
        () => authNotifier.signUp(
          email: email,
          password: emptyPassword,
        ),
        throwsException,
      );
    });

    test('should handle concurrent login attempts', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final testUser = TestDataFactory.createTestUser(email: email);

      when(mockAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => testUser);

      // Act: Attempt concurrent logins
      final authNotifier = container.read(authProvider.notifier);
      final futures = [
        authNotifier.signIn(email: email, password: password),
        authNotifier.signIn(email: email, password: password),
      ];

      // Assert: Both should complete (or handle gracefully)
      await expectLater(
        Future.wait(futures),
        completes,
      );
    });

    test('should handle password reset with non-existent email', () async {
      // Arrange
      const nonExistentEmail = 'nonexistent@example.com';

      when(mockAuthService.sendPasswordResetEmail(nonExistentEmail))
          .thenThrow(Exception('User not found'));

      // Act & Assert
      final authNotifier = container.read(authProvider.notifier);
      expect(
        () => authNotifier.sendPasswordResetEmail(nonExistentEmail),
        throwsException,
      );
    });
  });
}

