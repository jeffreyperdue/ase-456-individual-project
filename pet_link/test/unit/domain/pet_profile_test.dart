import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/pets/domain/pet_profile.dart';

void main() {
  group('PetProfile', () {
    test('copyWith updates selected fields and preserves others', () {
      final original = PetProfile(
        id: 'profile1',
        petId: 'pet1',
        ownerId: 'owner1',
        veterinarianContact: 'Vet A',
        emergencyContact: 'Emergency A',
        insuranceInfo: 'Insurance A',
        microchipId: '12345',
        allergies: 'Pollen',
        chronicConditions: 'Arthritis',
        vaccinationHistory: 'Up to date',
        lastCheckupDate: '2024-01-01',
        currentMedications: 'Med A',
        generalNotes: 'Very friendly',
        tags: ['senior', 'anxious'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final updated = original.copyWith(
        veterinarianContact: 'Vet B',
        generalNotes: 'New notes',
        tags: ['senior'],
      );

      expect(updated.id, original.id);
      expect(updated.petId, original.petId);
      expect(updated.ownerId, original.ownerId);
      expect(updated.veterinarianContact, 'Vet B');
      expect(updated.generalNotes, 'New notes');
      expect(updated.tags, ['senior']);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, original.updatedAt);
    });

    test('toJson and fromJson round-trip correctly including dates', () {
      final profile = PetProfile(
        id: 'profile1',
        petId: 'pet1',
        ownerId: 'owner1',
        veterinarianContact: 'Vet A',
        emergencyContact: 'Emergency A',
        insuranceInfo: 'Insurance A',
        microchipId: '12345',
        allergies: 'Pollen',
        chronicConditions: 'Arthritis',
        vaccinationHistory: 'Up to date',
        lastCheckupDate: '2024-01-01',
        currentMedications: 'Med A',
        generalNotes: 'Very friendly',
        tags: ['senior', 'anxious'],
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 2, 13, 30),
      );

      final json = profile.toJson();
      final fromJson = PetProfile.fromJson(json);

      expect(fromJson, equals(profile));
      expect(fromJson.createdAt, isNotNull);
      expect(fromJson.updatedAt, isNotNull);
    });

    test('equality and hashCode consider all fields', () {
      final a = PetProfile(
        id: 'profile1',
        petId: 'pet1',
        ownerId: 'owner1',
        tags: ['tag1'],
      );

      final b = PetProfile(
        id: 'profile1',
        petId: 'pet1',
        ownerId: 'owner1',
        tags: ['tag1'],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}


