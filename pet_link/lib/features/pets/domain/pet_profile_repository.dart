import 'pet_profile.dart';

/// Abstract interface for PetProfile data operations.
///
/// This repository defines the contract for storing and retrieving
/// enhanced pet profile information.
abstract class PetProfileRepository {
  /// Stream a pet profile for a specific pet.
  /// Returns null if no profile exists for the pet.
  Stream<PetProfile?> watchPetProfile(String petId);

  /// Save a pet profile (create or update).
  /// Returns the saved profile.
  Future<PetProfile> savePetProfile(PetProfile profile);

  /// Delete a pet profile.
  Future<void> deletePetProfile(String petId);
}
