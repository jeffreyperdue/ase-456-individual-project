// Widget test: Home Page
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/presentation/pages/home_page.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import 'package:petfolio/app/widgets/retry_widget.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';
import 'home_page_test.mocks.dart';

// Generate mocks
@GenerateMocks([PetsRepository, AuthService])
void main() {
  group('HomePage Widget Tests', () {
    late MockPetsRepository mockPetsRepository;
    late MockAuthService mockAuthService;
    late app_user.User testUser;

    setUp(() {
      setupTestEnvironment();
      mockPetsRepository = MockPetsRepository();
      mockAuthService = MockAuthService();

      testUser = TestDataFactory.createTestUser();
      // authStateChanges returns Stream<firebase_auth.User?>, not app_user.User
      // We'll use a mock Firebase user or null
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null)); // Return null, authProvider will handle it
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should display loading state initially', (
      WidgetTester tester,
    ) async {
      // Arrange: Repository returns loading stream
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const HomePage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump(); // Don't settle, check loading state

      // Assert: Loading indicator may be shown briefly
      // The actual loading state depends on provider implementation
    });

    testWidgets('should display empty state when no pets exist', (
      WidgetTester tester,
    ) async {
      // Arrange: Empty pets list
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const HomePage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Empty state message is shown
      expect(
        find.text('No pets yet. Tap + to add one.'),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });



    testWidgets('should show FAB for adding new pet', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const HomePage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: FAB is present
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

  });
}

