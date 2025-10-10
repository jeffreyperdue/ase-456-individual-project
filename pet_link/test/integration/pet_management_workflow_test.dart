import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../helpers/test_helpers.dart';
import 'pet_management_workflow_test.mocks.dart';

// Generate mocks
@GenerateMocks([PetsRepository])
void main() {
  group('Pet Management Workflow Integration Tests', () {
    late MockPetsRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockPetsRepository();
      container = ProviderContainer(
        overrides: [petsRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Pet Creation Workflow', () {
      test('should create pet successfully', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final newPet = TestDataFactory.createTestPet(
          ownerId: owner.id,
          name: 'New Pet',
          species: 'Cat',
          breed: 'Persian',
        );

        // Mock repository to return the created pet
        when(mockRepository.createPet(any)).thenAnswer((_) async {});
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([newPet]));

        // Set up authenticated user
        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        final petNotifier = container.read(petsProvider.notifier);
        await petNotifier.add(newPet);

        // Assert
        verify(mockRepository.createPet(newPet)).called(1);
      });

      test('should handle pet creation failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final newPet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(
          mockRepository.createPet(any),
        ).thenThrow(Exception('Failed to create pet'));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act & Assert
        final petNotifier = container.read(petsProvider.notifier);
        expect(() => petNotifier.add(newPet), throwsException);

        verify(mockRepository.createPet(newPet)).called(1);
      });

      test('should update pet list after successful creation', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final existingPet = TestDataFactory.createTestPet(
          ownerId: owner.id,
          name: 'Existing Pet',
        );
        final newPet = TestDataFactory.createTestPet(
          ownerId: owner.id,
          name: 'New Pet',
        );

        // Mock initial state with one pet
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([existingPet]));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act - initialize the provider
        await Future.delayed(Duration.zero); // Allow stream to emit

        // Verify initial state
        final initialState = container.read(petsProvider);
        expect(initialState.hasValue, isTrue);
        expect(initialState.value, contains(existingPet));

        // Mock updated state with both pets
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([existingPet, newPet]));
        when(mockRepository.createPet(any)).thenAnswer((_) async {});

        // Add new pet
        final petNotifier = container.read(petsProvider.notifier);
        await petNotifier.add(newPet);

        // Assert
        verify(mockRepository.createPet(newPet)).called(1);
      });
    });

    group('Pet Update Workflow', () {
      test('should update pet successfully', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(
          ownerId: owner.id,
          name: 'Original Name',
        );

        const updates = {'name': 'Updated Name', 'breed': 'New Breed'};

        when(
          mockRepository.updatePet(pet.id, updates),
        ).thenAnswer((_) async {});
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([pet]));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        final petNotifier = container.read(petsProvider.notifier);
        await petNotifier.update(pet.id, updates);

        // Assert
        verify(mockRepository.updatePet(pet.id, updates)).called(1);
      });

      test('should handle pet update failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        const petId = 'test_pet_id';
        const updates = {'name': 'Updated Name'};

        when(
          mockRepository.updatePet(petId, updates),
        ).thenThrow(Exception('Update failed'));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act & Assert
        final petNotifier = container.read(petsProvider.notifier);
        expect(() => petNotifier.update(petId, updates), throwsException);

        verify(mockRepository.updatePet(petId, updates)).called(1);
      });

      test('should update multiple pet fields', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        const petId = 'test_pet_id';
        final updates = {
          'name': 'New Name',
          'species': 'Dog',
          'breed': 'Labrador',
          'weightKg': 25.0,
          'heightCm': 60.0,
        };

        when(mockRepository.updatePet(petId, updates)).thenAnswer((_) async {});

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        final petNotifier = container.read(petsProvider.notifier);
        await petNotifier.update(petId, updates);

        // Assert
        verify(mockRepository.updatePet(petId, updates)).called(1);
      });
    });

    group('Pet Deletion Workflow', () {
      test('should delete pet successfully', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        const petId = 'test_pet_id';

        when(mockRepository.deletePet(petId)).thenAnswer((_) async {});

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        final petNotifier = container.read(petsProvider.notifier);
        await petNotifier.remove(petId);

        // Assert
        verify(mockRepository.deletePet(petId)).called(1);
      });

      test('should handle pet deletion failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        const petId = 'test_pet_id';

        when(
          mockRepository.deletePet(petId),
        ).thenThrow(Exception('Delete failed'));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act & Assert

        final petNotifier = container.read(petsProvider.notifier);
        expect(() => petNotifier.remove(petId), throwsException);

        verify(mockRepository.deletePet(petId)).called(1);
      });
    });

    group('Pet List Management', () {
      test('should load pets for authenticated user', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pets = [
          TestDataFactory.createTestPet(
            ownerId: owner.id,
            name: 'Pet 1',
            species: 'Dog',
          ),
          TestDataFactory.createTestPet(
            ownerId: owner.id,
            name: 'Pet 2',
            species: 'Cat',
          ),
        ];

        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value(pets));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        await Future.delayed(Duration.zero); // Allow stream to emit

        // Assert
        final petsState = container.read(petsProvider);
        expect(petsState.hasValue, isTrue);
        expect(petsState.value, equals(pets));
        expect(petsState.value, hasLength(2));
      });

      test('should handle empty pet list', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();

        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([]));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        await Future.delayed(Duration.zero);

        // Assert
        final petsState = container.read(petsProvider);
        expect(petsState.hasValue, isTrue);
        expect(petsState.value, isEmpty);
      });

      test('should handle repository errors', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();

        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.error(Exception('Repository error')));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act
        await Future.delayed(Duration.zero);

        // Assert
        final petsState = container.read(petsProvider);
        expect(petsState.hasError, isTrue);
        expect(petsState.error.toString(), contains('Repository error'));
      });

      test('should clear pets when user signs out', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pets = [TestDataFactory.createTestPet(ownerId: owner.id)];

        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value(pets));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act - initialize with pets
        await Future.delayed(Duration.zero);

        // Verify pets are loaded
        expect(container.read(petsProvider).value, isNotEmpty);

        // Sign out user
        container.read(authProvider.notifier).state = const AsyncValue.data(
          null,
        );

        // Assert - pets should be cleared
        final petsState = container.read(petsProvider);
        expect(petsState.value, isEmpty);
      });
    });

    group('Pet Data Validation', () {
      test('should validate pet creation data', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final invalidPet = Pet(
          id: '', // Empty ID
          ownerId: owner.id,
          name: '', // Empty name
          species: '', // Empty species
        );

        when(
          mockRepository.createPet(any),
        ).thenThrow(Exception('Invalid pet data'));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act & Assert

        final petNotifier = container.read(petsProvider.notifier);
        expect(() => petNotifier.add(invalidPet), throwsException);
      });

      test('should handle pet updates with invalid data', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        const petId = 'test_pet_id';
        final invalidUpdates = {
          'name': '', // Empty name
          'weightKg': -1.0, // Negative weight
        };

        when(
          mockRepository.updatePet(petId, invalidUpdates),
        ).thenThrow(Exception('Invalid update data'));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act & Assert

        final petNotifier = container.read(petsProvider.notifier);
        expect(
          () => petNotifier.update(petId, invalidUpdates),
          throwsException,
        );
      });
    });

    group('Concurrent Operations', () {
      test('should handle multiple pet operations concurrently', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet1 = TestDataFactory.createTestPet(
          ownerId: owner.id,
          name: 'Pet 1',
        );
        final pet2 = TestDataFactory.createTestPet(
          ownerId: owner.id,
          name: 'Pet 2',
        );

        when(mockRepository.createPet(any)).thenAnswer((_) async {});
        when(mockRepository.updatePet(any, any)).thenAnswer((_) async {});
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([pet1, pet2]));

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act

        // Perform multiple operations concurrently
        final petNotifier = container.read(petsProvider.notifier);
        await Future.wait([
          petNotifier.add(pet1),
          petNotifier.add(pet2),
          petNotifier.update(pet1.id, {'name': 'Updated Pet 1'}),
        ]);

        // Assert
        verify(mockRepository.createPet(pet1)).called(1);
        verify(mockRepository.createPet(pet2)).called(1);
        verify(
          mockRepository.updatePet(pet1.id, {'name': 'Updated Pet 1'}),
        ).called(1);
      });

      test('should handle repository stream updates', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final initialPets = [TestDataFactory.createTestPet(ownerId: owner.id)];
        final updatedPets = [
          ...initialPets,
          TestDataFactory.createTestPet(ownerId: owner.id, name: 'New Pet'),
        ];

        // Create a stream controller to simulate real-time updates
        final streamController = StreamController<List<Pet>>();

        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => streamController.stream);

        container.read(authProvider.notifier).state = AsyncValue.data(owner);

        // Act

        // Emit initial pets
        streamController.add(initialPets);
        await Future.delayed(Duration.zero);

        // Verify initial state
        expect(container.read(petsProvider).value, equals(initialPets));

        // Emit updated pets
        streamController.add(updatedPets);
        await Future.delayed(Duration.zero);

        // Verify updated state
        expect(container.read(petsProvider).value, equals(updatedPets));
        expect(container.read(petsProvider).value, hasLength(2));

        // Cleanup
        await streamController.close();
      });
    });
  });
}
