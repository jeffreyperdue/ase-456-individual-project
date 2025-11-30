// Widget test: Care Dashboard Page
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/care_plans/presentation/pages/care_dashboard_page.dart';
import 'package:petfolio/features/care_plans/domain/care_plan_repository.dart';
import 'package:petfolio/features/care_plans/application/providers.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';
import 'care_dashboard_page_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  CarePlanRepository,
  PetsRepository,
  AuthService,
])
void main() {
  group('CareDashboardPage Widget Tests', () {
    late MockCarePlanRepository mockCarePlanRepository;
    late MockPetsRepository mockPetsRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      setupTestEnvironment();
      mockCarePlanRepository = MockCarePlanRepository();
      mockPetsRepository = MockPetsRepository();
      mockAuthService = MockAuthService();

      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render correctly with all elements', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const CareDashboardPage(),
          overrides: [
            carePlanRepositoryProvider.overrideWithValue(mockCarePlanRepository),
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Key elements are present
      expect(find.text('Add Care Plan'), findsOneWidget);
      expect(find.text("Today's Tasks"), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should display care plan dashboard widget', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const CareDashboardPage(),
          overrides: [
            carePlanRepositoryProvider.overrideWithValue(mockCarePlanRepository),
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Dashboard is displayed
      expect(find.byType(CareDashboardPage), findsOneWidget);
    });

    testWidgets('should have FAB for today\'s tasks', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const CareDashboardPage(),
          overrides: [
            carePlanRepositoryProvider.overrideWithValue(mockCarePlanRepository),
            petsRepositoryProvider.overrideWithValue(mockPetsRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: FAB is present
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(find.text("Today's Tasks"), findsOneWidget);
    });
  });
}

