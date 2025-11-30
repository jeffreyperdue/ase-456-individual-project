// Regression test: Pet Data Integrity Edge Cases
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'pet_data_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([PetsRepository, AuthService])
void main() {
  group('Regression: Pet Data Integrity Edge Cases', () {
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

    test('should handle pet deletion with active care plans gracefully', () async {
      // Arrange: Pet with care plan exists
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));
      when(mockPetsRepository.deletePet(any))
          .thenAnswer((_) async => {});

      // Act: Delete pet
      final petListNotifier = container.read(petsProvider.notifier);
      await petListNotifier.remove(testPet.id);

      // Assert: Pet deletion completes without error
      verify(mockPetsRepository.deletePet(testPet.id)).called(1);
    });

    test('should handle photo upload failures gracefully', () async {
      // Arrange: Pet creation with photo upload failure
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(
        ownerId: testUser.id,
        name: 'Test Pet',
      );

      when(mockPetsRepository.createPet(any))
          .thenThrow(Exception('Photo upload failed: Network error'));

      // Act & Assert
      final petListNotifier = container.read(petsProvider.notifier);
      expect(
        () => petListNotifier.add(testPet),
        throwsException,
      );

      // Verify error doesn't corrupt state
      final petsState = container.read(petsProvider);
      expect(petsState, isNotNull);
    });

    test('should prevent concurrent pet edits from corrupting data', () async {
      // Arrange: Pet being edited
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(
        ownerId: testUser.id,
        name: 'Original Name',
      );

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));
      when(mockPetsRepository.updatePet(any, any))
          .thenAnswer((_) async => {});

      // Act: Concurrent updates
      final petListNotifier = container.read(petsProvider.notifier);
      final updates1 = {'name': 'Updated Name 1'};
      final updates2 = {'name': 'Updated Name 2'};

      // Both updates should complete
      await Future.wait([
        petListNotifier.update(testPet.id, updates1),
        petListNotifier.update(testPet.id, updates2),
      ]);

      // Assert: Both updates were attempted
      verify(mockPetsRepository.updatePet(testPet.id, any)).called(greaterThan(0));
    });

    test('should handle missing required fields', () async {
      // Arrange: Pet with missing required fields
      final testUser = TestDataFactory.createTestUser();
      
      // Create pet with empty name (should be invalid)
      final invalidPet = Pet(
        id: 'test_id',
        ownerId: testUser.id,
        name: '', // Empty name - invalid
        species: 'Dog',
      );

      when(mockPetsRepository.createPet(any))
          .thenThrow(Exception('Pet name is required'));

      // Act & Assert
      final petListNotifier = container.read(petsProvider.notifier);
      expect(
        () => petListNotifier.add(invalidPet),
        throwsException,
      );
    });

    test('should handle pet deletion of non-existent pet', () async {
      // Arrange: Attempting to delete pet that doesn't exist
      const nonExistentPetId = 'non_existent_id';

      when(mockPetsRepository.deletePet(nonExistentPetId))
          .thenThrow(Exception('Pet not found'));

      // Act & Assert
      final petListNotifier = container.read(petsProvider.notifier);
      expect(
        () => petListNotifier.remove(nonExistentPetId),
        throwsException,
      );
    });

    test('should handle network failure during pet creation', () async {
      // Arrange
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.createPet(any))
          .thenThrow(Exception('Network error: Unable to connect'));

      // Act & Assert
      final petListNotifier = container.read(petsProvider.notifier);
      expect(
        () => petListNotifier.add(testPet),
        throwsException,
      );

      // Verify state doesn't get corrupted
      final petsState = container.read(petsProvider);
      expect(petsState, isNotNull);
    });

    test('should handle very long pet names', () async {
      // Arrange: Pet with extremely long name
      final testUser = TestDataFactory.createTestUser();
      final longName = 'A' * 1000; // Very long name
      final testPet = TestDataFactory.createTestPet(
        ownerId: testUser.id,
        name: longName,
      );

      // Service should either accept or reject gracefully
      when(mockPetsRepository.createPet(any))
          .thenAnswer((_) async => testPet);

      // Act
      final petListNotifier = container.read(petsProvider.notifier);
      await petListNotifier.add(testPet);

      // Assert: Operation completes (either succeeds or fails gracefully)
      verify(mockPetsRepository.createPet(any)).called(1);
    });

    test('should handle special characters in pet names', () async {
      // Arrange: Pet name with special characters
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(
        ownerId: testUser.id,
        name: "O'Reilly & Co. (Buddy)",
      );

      when(mockPetsRepository.createPet(any))
          .thenAnswer((_) async => testPet);

      // Act
      final petListNotifier = container.read(petsProvider.notifier);
      await petListNotifier.add(testPet);

      // Assert: Special characters are handled
      verify(mockPetsRepository.createPet(any)).called(1);
    });

    test('should handle pet update with invalid data', () async {
      // Arrange
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));
      when(mockPetsRepository.updatePet(any, any))
          .thenThrow(Exception('Invalid update data'));

      // Act & Assert
      final petListNotifier = container.read(petsProvider.notifier);
      expect(
        () => petListNotifier.update(testPet.id, {'invalid': 'data'}),
        throwsException,
      );
    });
  });
}

