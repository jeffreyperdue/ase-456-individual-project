import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('Pet Domain Model Tests', () {
    test('should create pet with required fields', () {
      // Arrange & Act
      final pet = TestDataFactory.createTestPet();

      // Assert
      expect(pet.id, equals('test_pet_id'));
      expect(pet.ownerId, equals('test_user_id'));
      expect(pet.name, equals('Test Pet'));
      expect(pet.species, equals('Dog'));
      expect(pet.breed, equals('Golden Retriever'));
      expect(pet.isLost, isFalse);
      expect(pet.createdAt, isNotNull);
    });

    test('should create pet with optional fields', () {
      // Arrange & Act
      final pet = Pet(
        id: 'optional_pet_id',
        ownerId: 'owner_id',
        name: 'Optional Pet',
        species: 'Cat',
        breed: 'Siamese',
        dateOfBirth: DateTime(2019, 6, 15),
        weightKg: 4.5,
        heightCm: 25.0,
        photoUrl: 'https://example.com/photo.jpg',
        isLost: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      // Assert
      expect(pet.id, equals('optional_pet_id'));
      expect(pet.ownerId, equals('owner_id'));
      expect(pet.name, equals('Optional Pet'));
      expect(pet.species, equals('Cat'));
      expect(pet.breed, equals('Siamese'));
      expect(pet.dateOfBirth, equals(DateTime(2019, 6, 15)));
      expect(pet.weightKg, equals(4.5));
      expect(pet.heightCm, equals(25.0));
      expect(pet.photoUrl, equals('https://example.com/photo.jpg'));
      expect(pet.isLost, isTrue);
      expect(pet.createdAt, equals(DateTime(2024, 1, 1)));
      expect(pet.updatedAt, equals(DateTime(2024, 1, 2)));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final pet = TestDataFactory.createTestPet();

      // Act
      final json = pet.toJson();

      // Assert
      expect(json['id'], equals('test_pet_id'));
      expect(json['ownerId'], equals('test_user_id'));
      expect(json['name'], equals('Test Pet'));
      expect(json['species'], equals('Dog'));
      expect(json['breed'], equals('Golden Retriever'));
      expect(json['isLost'], isFalse);
      expect(json['createdAt'], isNotNull);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'json_pet_id',
        'ownerId': 'json_owner_id',
        'name': 'JSON Pet',
        'species': 'Bird',
        'breed': 'Parrot',
        'dateOfBirth': '2018-03-10T00:00:00.000Z',
        'weightKg': 0.5,
        'heightCm': 15.0,
        'photoUrl': 'https://example.com/bird.jpg',
        'isLost': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final pet = Pet.fromJson(json);

      // Assert
      expect(pet.id, equals('json_pet_id'));
      expect(pet.ownerId, equals('json_owner_id'));
      expect(pet.name, equals('JSON Pet'));
      expect(pet.species, equals('Bird'));
      expect(pet.breed, equals('Parrot'));
      expect(
        pet.dateOfBirth,
        equals(DateTime.parse('2018-03-10T00:00:00.000Z')),
      );
      expect(pet.weightKg, equals(0.5));
      expect(pet.heightCm, equals(15.0));
      expect(pet.photoUrl, equals('https://example.com/bird.jpg'));
      expect(pet.isLost, isTrue);
      expect(pet.createdAt, equals(DateTime.parse('2024-01-01T00:00:00.000Z')));
      expect(pet.updatedAt, equals(DateTime.parse('2024-01-02T00:00:00.000Z')));
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'id': 'minimal_pet_id',
        'ownerId': 'minimal_owner_id',
        'name': 'Minimal Pet',
        'species': 'Fish',
      };

      // Act
      final pet = Pet.fromJson(json);

      // Assert
      expect(pet.id, equals('minimal_pet_id'));
      expect(pet.ownerId, equals('minimal_owner_id'));
      expect(pet.name, equals('Minimal Pet'));
      expect(pet.species, equals('Fish'));
      expect(pet.breed, isNull);
      expect(pet.dateOfBirth, isNull);
      expect(pet.weightKg, isNull);
      expect(pet.heightCm, isNull);
      expect(pet.photoUrl, isNull);
      expect(pet.isLost, isFalse); // Default value
      expect(pet.createdAt, isNull);
      expect(pet.updatedAt, isNull);
    });

    test('should copy with updated fields', () {
      // Arrange
      final originalPet = TestDataFactory.createTestPet();

      // Act
      final updatedPet = originalPet.copyWith(
        name: 'Updated Pet Name',
        weightKg: 30.0,
        isLost: true,
      );

      // Assert
      expect(updatedPet.id, equals(originalPet.id));
      expect(updatedPet.ownerId, equals(originalPet.ownerId));
      expect(updatedPet.name, equals('Updated Pet Name'));
      expect(updatedPet.species, equals(originalPet.species));
      expect(updatedPet.weightKg, equals(30.0));
      expect(updatedPet.isLost, isTrue);
      expect(updatedPet.createdAt, equals(originalPet.createdAt));
    });

    test('should preserve original values when copyWith fields are null', () {
      // Arrange
      final originalPet = TestDataFactory.createTestPet();

      // Act
      final copiedPet = originalPet.copyWith();

      // Assert
      expect(copiedPet.id, equals(originalPet.id));
      expect(copiedPet.ownerId, equals(originalPet.ownerId));
      expect(copiedPet.name, equals(originalPet.name));
      expect(copiedPet.species, equals(originalPet.species));
      expect(copiedPet.breed, equals(originalPet.breed));
      expect(copiedPet.dateOfBirth, equals(originalPet.dateOfBirth));
      expect(copiedPet.weightKg, equals(originalPet.weightKg));
      expect(copiedPet.heightCm, equals(originalPet.heightCm));
      expect(copiedPet.photoUrl, equals(originalPet.photoUrl));
      expect(copiedPet.isLost, equals(originalPet.isLost));
      expect(copiedPet.createdAt, equals(originalPet.createdAt));
      expect(copiedPet.updatedAt, equals(originalPet.updatedAt));
    });

    test('should support equality comparison', () {
      // Arrange
      final pet1 = TestDataFactory.createTestPet();
      final pet2 = TestDataFactory.createTestPet();
      final pet3 = TestDataFactory.createTestPet(name: 'Different Pet');

      // Act & Assert
      expect(pet1, equals(pet2));
      expect(pet1, isNot(equals(pet3)));
      expect(pet1.hashCode, equals(pet2.hashCode));
    });

    test('should have meaningful toString representation', () {
      // Arrange
      final pet = TestDataFactory.createTestPet();

      // Act
      final stringRepresentation = pet.toString();

      // Assert
      expect(stringRepresentation, contains('test_pet_id'));
      expect(stringRepresentation, contains('Test Pet'));
      expect(stringRepresentation, contains('Dog'));
    });

    test('should calculate age correctly when dateOfBirth is provided', () {
      // Arrange
      final birthDate = DateTime(2020, 1, 1);
      final currentDate = DateTime(2024, 1, 1);

      final pet = Pet(
        id: 'age_test_pet',
        ownerId: 'owner_id',
        name: 'Age Test Pet',
        species: 'Dog',
        dateOfBirth: birthDate,
      );

      // Act
      final age = pet.calculateAge(currentDate);

      // Assert
      expect(age, equals(4)); // 4 years old
    });

    test('should return null age when dateOfBirth is not provided', () {
      // Arrange
      final pet = Pet(
        id: 'no_age_pet',
        ownerId: 'owner_id',
        name: 'No Age Pet',
        species: 'Cat',
      );

      // Act
      final age = pet.calculateAge(DateTime.now());

      // Assert
      expect(age, isNull);
    });

    test('should handle edge case for age calculation', () {
      // Arrange
      final birthDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 1, 1); // Same day

      final pet = Pet(
        id: 'same_day_pet',
        ownerId: 'owner_id',
        name: 'Same Day Pet',
        species: 'Dog',
        dateOfBirth: birthDate,
      );

      // Act
      final age = pet.calculateAge(currentDate);

      // Assert
      expect(age, equals(0)); // 0 years old (same day)
    });
  });
}
