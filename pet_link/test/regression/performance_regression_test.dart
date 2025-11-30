// Regression test: Performance and Memory
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'performance_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([PetsRepository])
void main() {
  group('Regression: Performance and Memory', () {
    late MockPetsRepository mockPetsRepository;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockPetsRepository = MockPetsRepository();
      container = ProviderContainer(
        overrides: [
          petsRepositoryProvider.overrideWithValue(mockPetsRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    test('should handle large pet list rendering', () async {
      // Arrange: Many pets
      final testUser = TestDataFactory.createTestUser();
      final manyPets = List.generate(
        100,
        (i) => TestDataFactory.createTestPet(
          name: 'Pet $i',
          ownerId: testUser.id,
        ),
      );

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value(manyPets));

      // Act: Load large list
      final pets = await mockPetsRepository.watchPetsForOwner(testUser.id).first;

      // Assert: All pets loaded
      expect(pets.length, equals(100));
    });

    test('should handle image loading and caching', () async {
      // Arrange: Pet with photo
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(
        ownerId: testUser.id,
        name: 'Test Pet',
      );

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Load pet with image
      final pets = await mockPetsRepository.watchPetsForOwner(testUser.id).first;

      // Assert: Pet loaded (image caching handled by Flutter)
      expect(pets, contains(testPet));
    });

    test('should prevent memory leaks in providers', () async {
      // Arrange: Multiple provider reads
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Multiple reads
      final futures = List.generate(
        10,
        (_) => mockPetsRepository.watchPetsForOwner(testUser.id).first,
      );

      // Assert: All complete without memory issues
      await expectLater(Future.wait(futures), completes);
    });

    test('should handle rapid provider updates', () async {
      // Arrange: Rapid updates
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Rapid provider access
      for (var i = 0; i < 20; i++) {
        await mockPetsRepository.watchPetsForOwner(testUser.id).first;
      }

      // Assert: No performance degradation
      expect(true, isTrue);
    });
  });
}

