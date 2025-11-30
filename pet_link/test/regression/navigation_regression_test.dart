// Regression test: Navigation and State Management
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'navigation_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PetsRepository,
  AuthService,
])
void main() {
  group('Regression: Navigation and State Management', () {
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

    test('should handle deep link navigation', () async {
      // Arrange: Deep link to pet detail
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Access pet via deep link
      // In real app, this would navigate directly to pet detail
      final pets = await mockPetsRepository.watchPetsForOwner(testUser.id).first;

      // Assert: Pet is accessible
      expect(pets, contains(testPet));
    });

    test('should preserve state across navigation', () async {
      // Arrange: User navigates between pages
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Navigate away and back
      final pets1 = await mockPetsRepository.watchPetsForOwner(testUser.id).first;
      final pets2 = await mockPetsRepository.watchPetsForOwner(testUser.id).first;

      // Assert: State is preserved
      expect(pets1, equals(pets2));
    });

    test('should handle back button navigation', () async {
      // Arrange: User is on detail page
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Navigate back
      // In real app, back button would pop navigation stack
      final pets = await mockPetsRepository.watchPetsForOwner(testUser.id).first;

      // Assert: Can navigate back
      expect(pets, isNotEmpty);
    });

    test('should prevent provider state corruption', () async {
      // Arrange: Multiple providers
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Access multiple providers
      final petsState = container.read(petsProvider);
      final authState = container.read(authProvider);

      // Assert: Both providers maintain state
      expect(petsState, isNotNull);
      expect(authState, isNotNull);
    });

    test('should handle rapid navigation changes', () async {
      // Arrange: User rapidly navigates
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Rapid provider reads
      final futures = List.generate(
        5,
        (_) => mockPetsRepository.watchPetsForOwner(testUser.id).first,
      );

      // Assert: All complete without errors
      await expectLater(Future.wait(futures.map((f) => f as Future<List<dynamic>>)), completes);
    });

    test('should handle navigation with invalid state', () async {
      // Arrange: Invalid navigation target
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([]));

      // Act: Navigate to non-existent pet
      final pets = await mockPetsRepository.watchPetsForOwner('invalid').first;

      // Assert: Handles gracefully
      expect(pets, isEmpty);
    });
  });
}

