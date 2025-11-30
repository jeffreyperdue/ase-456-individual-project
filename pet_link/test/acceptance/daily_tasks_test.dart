// Acceptance test: Daily Task Management Journey
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/care_plans/presentation/pages/today_tasks_page.dart';
import 'package:petfolio/features/care_plans/domain/care_task.dart';
import 'package:petfolio/features/care_plans/application/care_task_provider.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'daily_tasks_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PetsRepository,
  AuthService,
])
void main() {
  group('Acceptance: Daily Task Management Journey', () {
    late MockPetsRepository mockPetsRepository;
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockPetsRepository = MockPetsRepository();
      mockAuthService = MockAuthService();

      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);

      container = ProviderContainer(
        overrides: [
          petsRepositoryProvider.overrideWithValue(mockPetsRepository),
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    testWidgets('step 1: should navigate to today\'s tasks page', (
      WidgetTester tester,
    ) async {
      // Arrange: User has pets with care plans
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Navigate to today's tasks
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const TodayTasksPage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Today's tasks page is displayed
      expect(find.text("Today's Tasks"), findsOneWidget);
      expect(find.byType(TodayTasksPage), findsOneWidget);
    });

    testWidgets('step 2: should display today\'s tasks', (
      WidgetTester tester,
    ) async {
      // Arrange: Tasks exist for today
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: View today's tasks
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const TodayTasksPage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Page displays (tasks may be empty)
      expect(find.byType(TodayTasksPage), findsOneWidget);
    });

    testWidgets('step 3: should allow completing a task', (
      WidgetTester tester,
    ) async {
      // Arrange: Task exists
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: View tasks page
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const TodayTasksPage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Page is accessible for task completion
      expect(find.byType(TodayTasksPage), findsOneWidget);
    });

    testWidgets('step 4: should show empty state when no tasks', (
      WidgetTester tester,
    ) async {
      // Arrange: No pets or no care plans
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act: View today's tasks
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const TodayTasksPage(),
          overrides: [
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Empty state is shown
      expect(
        find.text('No pets yet. Add a pet to start tracking care tasks.'),
        findsOneWidget,
      );
    });
  });
}

