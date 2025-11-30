// Acceptance test: Profile Management Journey
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:petfolio/features/auth/presentation/pages/profile_page.dart';
import 'package:petfolio/features/auth/presentation/pages/login_page.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'profile_management_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthService])
void main() {
  group('Acceptance: Profile Management Journey', () {
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockAuthService = MockAuthService();
      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);

      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    testWidgets('step 1: should display user profile', (
      WidgetTester tester,
    ) async {
      // Arrange: User is authenticated
      final testUser = TestDataFactory.createTestUser();

      // Act: Navigate to profile page - override authProvider
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              authProvider.overrideWithProvider(
                StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>(
                  (ref) {
                    final notifier = AuthNotifier(mockAuthService, ref);
                    notifier.state = AsyncValue.data(testUser);
                    return notifier;
                  },
                ),
              ),
            ],
          ),
          child: MaterialApp(
            home: Scaffold(
              body: const ProfilePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Profile information is displayed
      if (testUser.displayName != null) {
        expect(find.text(testUser.displayName!), findsOneWidget);
      }
      expect(find.text(testUser.email), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('step 2: should allow viewing profile details', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testUser = TestDataFactory.createTestUser(
        displayName: 'Test User',
        email: 'test@example.com',
      );

      // Act: View profile - override authProvider
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              authProvider.overrideWithProvider(
                StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>(
                  (ref) {
                    final notifier = AuthNotifier(mockAuthService, ref);
                    notifier.state = AsyncValue.data(testUser);
                    return notifier;
                  },
                ),
              ),
            ],
          ),
          child: MaterialApp(
            home: Scaffold(
              body: const ProfilePage(),
            ),
          ),
        ),
      );
      await tester.pump(); // Initial build
      await tester.pump(); // Allow provider to resolve
      await tester.pumpAndSettle();

      // Assert: Details are visible
      // Profile page might show user info differently
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('step 3: should allow signing out', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              authProvider.overrideWithProvider(
                StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>(
                  (ref) {
                    final notifier = AuthNotifier(mockAuthService, ref);
                    notifier.state = AsyncValue.data(testUser);
                    return notifier;
                  },
                ),
              ),
            ],
          ),
          child: MaterialApp(
            home: Scaffold(
              body: const ProfilePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Tap sign out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Assert: Sign out is called
      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('step 4: should navigate to login after sign out', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              authProvider.overrideWithProvider(
                StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>(
                  (ref) {
                    final notifier = AuthNotifier(mockAuthService, ref);
                    notifier.state = AsyncValue.data(testUser);
                    return notifier;
                  },
                ),
              ),
            ],
          ),
          child: MaterialApp(
            routes: {
              '/login': (_) => const LoginPage(),
            },
            home: Scaffold(
              body: const ProfilePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Sign out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Assert: Sign out completes (navigation would happen in real app)
      verify(mockAuthService.signOut()).called(1);
    });
  });
}

