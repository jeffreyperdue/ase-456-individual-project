// Acceptance test: New User Onboarding Journey
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/presentation/pages/login_page.dart';
import 'package:petfolio/features/auth/presentation/pages/signup_page.dart';
import 'package:petfolio/features/onboarding/welcome_view.dart';
import 'package:petfolio/features/pets/presentation/pages/home_page.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/services/local_storage_provider.dart';
import 'package:petfolio/services/local_storage_service.dart';
import 'package:petfolio/app/config.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'new_user_onboarding_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthService, LocalStorageService, PetsRepository])
void main() {
  group('Acceptance: New User Onboarding Journey', () {
    late MockAuthService mockAuthService;
    late MockLocalStorageService mockLocalStorageService;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockAuthService = MockAuthService();
      mockLocalStorageService = MockLocalStorageService();
      
      // Stub authStateChanges to return an empty stream initially
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      
      // Stub localStorage to indicate user hasn't seen welcome screen
      when(mockLocalStorageService.hasSeenWelcome())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.setHasSeenWelcome())
          .thenAnswer((_) async => {});

      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          localStorageServiceProvider.overrideWithValue(mockLocalStorageService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    testWidgets('step 1: should show welcome screen for first-time user', (
      WidgetTester tester,
    ) async {
      // Arrange: User hasn't seen welcome screen
      when(mockLocalStorageService.hasSeenWelcome())
          .thenAnswer((_) async => false);

      // Act: Navigate to welcome view
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const WelcomeView(),
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockLocalStorageService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Welcome screen is displayed
      expect(find.text('Welcome to Petfolio'), findsOneWidget);
      expect(find.text('Your shared hub for pet care'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });


    testWidgets('step 5: should show empty pet list on home after signup', (
      WidgetTester tester,
    ) async {
      // Arrange: User is authenticated with no pets
      final testUser = TestDataFactory.createTestUser();
      final mockPetsRepository = MockPetsRepository();
      
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([])); // Empty list

      // Act: Navigate to home page
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
              petsRepositoryProvider.overrideWithValue(mockPetsRepository),
              // petsProvider will use the repository which returns empty list
            ],
          ),
          child: MaterialApp(home: Scaffold(body: const HomePage())),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Empty state is shown
      expect(
        find.text('No pets yet. Tap + to add one.'),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

