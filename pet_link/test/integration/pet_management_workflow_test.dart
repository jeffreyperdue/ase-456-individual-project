import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import '../helpers/test_helpers.dart';
import 'pet_management_workflow_test.mocks.dart';

// Generate mocks
@GenerateMocks([PetsRepository, AuthService, firebase_auth.User])
void main() {
  group('Pet Management Workflow Integration Tests', () {
    late MockPetsRepository mockRepository;
    late MockAuthService mockAuthService;
    late ProviderContainer container;
    late StreamController<firebase_auth.User?> authStateController;

    setUp(() {
      mockRepository = MockPetsRepository();
      mockAuthService = MockAuthService();
      authStateController = StreamController<firebase_auth.User?>.broadcast();
      
      // Stub authStateChanges to return our controllable stream
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => authStateController.stream);
      
      container = ProviderContainer(
        overrides: [
          petsRepositoryProvider.overrideWithValue(mockRepository),
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      authStateController.close();
      container.dispose();
    });
    
    // Helper method to set authenticated user in tests
    Future<void> setAuthenticatedUser(app_user.User user, MockUser mockFirebaseUser) async {
      // Stub getCurrentAppUser to return the user
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => user);
      
      // Initialize authProvider first to set up the stream subscription
      // This ensures the AuthNotifier is created and listening before we emit values
      container.read(authProvider);
      
      // Wait a bit for the subscription to be set up
      await Future.delayed(Duration.zero);
      
      // Emit a Firebase user through the stream to trigger auth state change
      authStateController.add(mockFirebaseUser);
      
      // Wait for the auth state to propagate through the async chain
      // AuthNotifier receives stream -> calls getCurrentAppUser() -> updates state
      await Future.delayed(Duration.zero);
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Poll until the auth provider has the user (with timeout)
      var attempts = 0;
      while (attempts < 10) {
        final authState = container.read(authProvider);
        if (authState.hasValue && authState.value != null) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }
      
      // Verify the auth provider has the user
      final authState = container.read(authProvider);
      expect(authState.hasValue, isTrue, reason: 'Auth provider should have user');
      expect(authState.value, isNotNull, reason: 'Auth provider user should not be null');
    }
    
    // Helper method to set unauthenticated user in tests
    Future<void> setUnauthenticatedUser() async {
      // Emit null through the stream to trigger sign out
      authStateController.add(null);
      
      // Wait for the auth state to propagate
      await Future.delayed(Duration.zero);
      await Future.delayed(const Duration(milliseconds: 50));
    }

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
        when(mockRepository.createPet(any)).thenAnswer((_) async => Future<void>.value());
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([newPet]));

        // Set up authenticated user
        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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

        // Use StreamController to control when values are emitted
        final petsStreamController = StreamController<List<Pet>>.broadcast();
        
        // Mock initial state with one pet
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => petsStreamController.stream);

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

        // Initialize petsProvider to ensure PetListNotifier is created
        // and listening to currentUserDataProvider changes
        container.read(petsProvider);
        
        // Wait for PetListNotifier to detect user change and subscribe to the stream
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Emit initial pets after subscription is set up
        petsStreamController.add([existingPet]);
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify initial state - poll until it's ready
        var attempts = 0;
        while (attempts < 10) {
          final state = container.read(petsProvider);
          if (state.hasValue) {
            expect(state.value, contains(existingPet));
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          attempts++;
        }
        final initialState = container.read(petsProvider);
        expect(initialState.hasValue, isTrue);
        expect(initialState.value, contains(existingPet));

        // Mock create pet
        when(mockRepository.createPet(any)).thenAnswer((_) async => Future<void>.value());

        // Add new pet
        final petNotifier = container.read(petsProvider.notifier);
        await petNotifier.add(newPet);

        // Simulate stream update with both pets (as Firestore would do)
        petsStreamController.add([existingPet, newPet]);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        verify(mockRepository.createPet(newPet)).called(1);
        
        // Cleanup
        await petsStreamController.close();
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
        ).thenAnswer((_) async => Future<void>.value());
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([pet]));

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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

        when(mockRepository.updatePet(petId, updates)).thenAnswer((_) async => Future<void>.value());
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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

        when(mockRepository.deletePet(petId)).thenAnswer((_) async => Future<void>.value());
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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

        // Use StreamController to control when values are emitted
        final petsStreamController = StreamController<List<Pet>>.broadcast();
        
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => petsStreamController.stream);

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

        // Initialize petsProvider to ensure PetListNotifier is created
        container.read(petsProvider);
        
        // Wait for PetListNotifier to detect user change and subscribe to the stream
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Emit pets after subscription is set up
        petsStreamController.add(pets);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - poll until ready
        var attempts = 0;
        while (attempts < 10) {
          final state = container.read(petsProvider);
          if (state.hasValue) {
            expect(state.value, equals(pets));
            expect(state.value, hasLength(2));
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          attempts++;
        }
        final petsState = container.read(petsProvider);
        expect(petsState.hasValue, isTrue);
        expect(petsState.value, equals(pets));
        expect(petsState.value, hasLength(2));
        
        // Cleanup
        await petsStreamController.close();
      });

      test('should handle empty pet list', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();

        // Use StreamController to control when values are emitted
        final petsStreamController = StreamController<List<Pet>>.broadcast();
        
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => petsStreamController.stream);

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

        // Initialize petsProvider to ensure PetListNotifier is created
        container.read(petsProvider);
        
        // Wait for PetListNotifier to detect user change and subscribe to the stream
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Emit empty list after subscription is set up
        petsStreamController.add([]);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - poll until ready
        var attempts = 0;
        while (attempts < 10) {
          final state = container.read(petsProvider);
          if (state.hasValue) {
            expect(state.value, isEmpty);
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          attempts++;
        }
        final petsState = container.read(petsProvider);
        expect(petsState.hasValue, isTrue);
        expect(petsState.value, isEmpty);
        
        // Cleanup
        await petsStreamController.close();
      });

      test('should handle repository errors', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();

        // Use StreamController to control when errors are emitted
        final petsStreamController = StreamController<List<Pet>>.broadcast();
        
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => petsStreamController.stream);

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

        // Initialize petsProvider to ensure PetListNotifier is created
        container.read(petsProvider);
        
        // Wait for PetListNotifier to detect user change and subscribe to the stream
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Emit error after subscription is set up
        petsStreamController.addError(Exception('Repository error'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - poll until error is set
        var attempts = 0;
        while (attempts < 10) {
          final state = container.read(petsProvider);
          if (state.hasError) {
            expect(state.error.toString(), contains('Repository error'));
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          attempts++;
        }
        final petsState = container.read(petsProvider);
        expect(petsState.hasError, isTrue);
        expect(petsState.error.toString(), contains('Repository error'));
        
        // Cleanup
        await petsStreamController.close();
      });

      test('should clear pets when user signs out', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pets = [TestDataFactory.createTestPet(ownerId: owner.id)];

        // Use StreamController to control when values are emitted
        final petsStreamController = StreamController<List<Pet>>.broadcast();
        
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => petsStreamController.stream);

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

        // Initialize petsProvider to ensure PetListNotifier is created
        container.read(petsProvider);
        
        // Wait for PetListNotifier to detect user change and subscribe to the stream
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Emit pets after subscription is set up
        petsStreamController.add(pets);
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify pets are loaded - poll until ready
        var attempts = 0;
        while (attempts < 10) {
          final state = container.read(petsProvider);
          if (state.hasValue && state.value != null && state.value!.isNotEmpty) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          attempts++;
        }
        expect(container.read(petsProvider).value, isNotEmpty);

        // Sign out user
        await setUnauthenticatedUser();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - pets should be cleared
        final petsState = container.read(petsProvider);
        expect(petsState.value, isEmpty);
        
        // Cleanup
        await petsStreamController.close();
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
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => const Stream.empty());

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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

        when(mockRepository.createPet(any)).thenAnswer((_) async => Future<void>.value());
        when(mockRepository.updatePet(any, any)).thenAnswer((_) async => Future<void>.value());
        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => Stream.value([pet1, pet2]));

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

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
        final streamController = StreamController<List<Pet>>.broadcast();

        when(
          mockRepository.watchPetsForOwner(owner.id),
        ).thenAnswer((_) => streamController.stream);

        final mockFirebaseUser = MockUser();
        when(mockFirebaseUser.uid).thenReturn(owner.id);
        await setAuthenticatedUser(owner, mockFirebaseUser);

        // Initialize petsProvider to ensure PetListNotifier is created
        container.read(petsProvider);
        
        // Wait for PetListNotifier to detect user change and subscribe to the stream
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - Emit initial pets
        streamController.add(initialPets);
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify initial state - poll until ready
        var attempts = 0;
        while (attempts < 10) {
          final state = container.read(petsProvider);
          if (state.hasValue && state.value != null) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
          attempts++;
        }
        expect(container.read(petsProvider).value, equals(initialPets));

        // Emit updated pets
        streamController.add(updatedPets);
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify updated state
        expect(container.read(petsProvider).value, equals(updatedPets));
        expect(container.read(petsProvider).value, hasLength(2));

        // Cleanup
        await streamController.close();
      });
    });
  });
}
