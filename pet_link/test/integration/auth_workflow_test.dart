import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../helpers/test_helpers.dart';
import 'auth_workflow_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthService])
void main() {
  group('Authentication Workflow Integration Tests', () {
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('User Sign Up Workflow', () {
      test('should complete sign up workflow successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'testpassword123';
        const displayName = 'Test User';

        final expectedUser = TestDataFactory.createTestUser(
          email: email,
          displayName: displayName,
        );

        when(
          mockAuthService.signUpWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          ),
        ).thenAnswer((_) async => expectedUser);

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signUp(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        final authState = container.read(authProvider);
        expect(authState.hasValue, isTrue);
        expect(authState.value, equals(expectedUser));

        verify(
          mockAuthService.signUpWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          ),
        ).called(1);
      });

      test('should handle sign up failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'weakpassword';
        const displayName = 'Test User';

        const errorMessage = 'Password is too weak';
        when(
          mockAuthService.signUpWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          ),
        ).thenThrow(Exception(errorMessage));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.signUp(
            email: email,
            password: password,
            displayName: displayName,
          ),
          throwsException,
        );

        // Verify error state
        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
        expect(authState.error.toString(), contains(errorMessage));

        verify(
          mockAuthService.signUpWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          ),
        ).called(1);
      });

      test('should handle network error during sign up', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'testpassword123';

        when(
          mockAuthService.signUpWithEmailAndPassword(
            email: email,
            password: password,
            displayName: anyNamed('displayName'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.signUp(email: email, password: password),
          throwsException,
        );

        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });
    });

    group('User Sign In Workflow', () {
      test('should complete sign in workflow successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'testpassword123';

        final expectedUser = TestDataFactory.createTestUser(email: email);

        when(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => expectedUser);

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signIn(email: email, password: password);

        // Assert
        final authState = container.read(authProvider);
        expect(authState.hasValue, isTrue);
        expect(authState.value, equals(expectedUser));

        verify(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test('should handle invalid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.signIn(email: email, password: password),
          throwsException,
        );

        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });

      test('should handle user not found', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const password = 'testpassword123';

        when(
          mockAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(Exception('User not found'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.signIn(email: email, password: password),
          throwsException,
        );

        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });
    });

    group('User Sign Out Workflow', () {
      test('should complete sign out workflow successfully', () async {
        // Arrange
        final signedInUser = TestDataFactory.createTestUser();

        // Set initial signed in state
        container.read(authProvider.notifier).state = AsyncValue.data(
          signedInUser,
        );

        when(mockAuthService.signOut()).thenAnswer((_) async {});

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signOut();

        // Assert
        final authState = container.read(authProvider);
        expect(authState.hasValue, isTrue);
        expect(authState.value, isNull);

        verify(mockAuthService.signOut()).called(1);
      });

      test('should handle sign out failure', () async {
        // Arrange
        final signedInUser = TestDataFactory.createTestUser();
        container.read(authProvider.notifier).state = AsyncValue.data(
          signedInUser,
        );

        when(mockAuthService.signOut()).thenThrow(Exception('Sign out failed'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(() => authNotifier.signOut(), throwsException);

        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });
    });

    group('Password Reset Workflow', () {
      test('should send password reset email successfully', () async {
        // Arrange
        const email = 'test@example.com';

        when(
          mockAuthService.sendPasswordResetEmail(email),
        ).thenAnswer((_) async {});

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.sendPasswordResetEmail(email);

        // Assert
        verify(mockAuthService.sendPasswordResetEmail(email)).called(1);
      });

      test('should handle password reset email failure', () async {
        // Arrange
        const email = 'invalid@example.com';

        when(
          mockAuthService.sendPasswordResetEmail(email),
        ).thenThrow(Exception('Email not found'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.sendPasswordResetEmail(email),
          throwsException,
        );

        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });
    });

    group('Auth State Management', () {
      test('should initialize with loading state', () {
        // Act
        final authNotifier = container.read(authProvider.notifier);
        authNotifier.state = const AsyncValue.loading();

        // Assert
        final authState = container.read(authProvider);
        expect(authState.isLoading, isTrue);
      });

      test('should handle auth state changes', () async {
        // Arrange
        final user1 = TestDataFactory.createTestUser(id: 'user1');
        final user2 = TestDataFactory.createTestUser(id: 'user2');

        // Act
        final authNotifier = container.read(authProvider.notifier);

        authNotifier.state = AsyncValue.data(user1);
        expect(container.read(authProvider).value, equals(user1));

        authNotifier.state = AsyncValue.data(user2);
        expect(container.read(authProvider).value, equals(user2));

        authNotifier.state = const AsyncValue.data(null);
        expect(container.read(authProvider).value, isNull);
      });

      test('should clear user data on sign out', () async {
        // Arrange
        final signedInUser = TestDataFactory.createTestUser();
        container.read(authProvider.notifier).state = AsyncValue.data(
          signedInUser,
        );

        when(mockAuthService.signOut()).thenAnswer((_) async {});

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signOut();

        // Assert
        final authState = container.read(authProvider);
        expect(authState.value, isNull);
      });
    });

    group('User Profile Management', () {
      test('should update user profile successfully', () async {
        // Arrange
        final originalUser = TestDataFactory.createTestUser();
        final updatedUser = originalUser.copyWith(
          displayName: 'Updated Name',
          photoUrl: 'https://example.com/new-photo.jpg',
        );

        container.read(authProvider.notifier).state = AsyncValue.data(
          originalUser,
        );

        when(mockAuthService.updateUserProfile(any)).thenAnswer((_) async {});

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.updateProfile(updatedUser);

        // Assert
        verify(mockAuthService.updateUserProfile(updatedUser)).called(1);
      });

      test('should handle profile update failure', () async {
        // Arrange
        final user = TestDataFactory.createTestUser();
        final updatedUser = user.copyWith(displayName: 'New Name');

        container.read(authProvider.notifier).state = AsyncValue.data(user);

        when(
          mockAuthService.updateUserProfile(any),
        ).thenThrow(Exception('Update failed'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(() => authNotifier.updateProfile(updatedUser), throwsException);

        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });
    });

    group('Error Recovery', () {
      test('should recover from error state', () async {
        // Arrange
        final user = TestDataFactory.createTestUser();
        container.read(authProvider.notifier).state = AsyncValue.error(
          Exception('Previous error'),
          StackTrace.current,
        );

        when(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => user);

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.signIn(email: user.email, password: 'password');

        // Assert
        final authState = container.read(authProvider);
        expect(authState.hasValue, isTrue);
        expect(authState.value, equals(user));
      });

      test('should maintain error state across multiple operations', () async {
        // Arrange
        container.read(authProvider.notifier).state = AsyncValue.error(
          Exception('Persistent error'),
          StackTrace.current,
        );

        when(mockAuthService.signOut()).thenThrow(Exception('Sign out failed'));

        // Act & Assert
        final authNotifier = container.read(authProvider.notifier);

        expect(() => authNotifier.signOut(), throwsException);

        // Error should persist
        final authState = container.read(authProvider);
        expect(authState.hasError, isTrue);
      });
    });
  });
}
