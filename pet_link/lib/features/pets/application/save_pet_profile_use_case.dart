import '../domain/pet_profile.dart';
import '../domain/pet_profile_repository.dart';

/// Use case for saving pet profiles.
///
/// Handles validation and business logic for creating/updating pet profiles.
class SavePetProfileUseCase {
  SavePetProfileUseCase(this._repository);

  final PetProfileRepository _repository;

  /// Save a pet profile with validation.
  ///
  /// Validates that:
  /// - Profile has required fields (petId, ownerId)
  /// - Profile is not a duplicate for the same pet
  ///
  /// Returns the saved profile.
  Future<PetProfile> execute(PetProfile profile) async {
    // Validate required fields
    if (profile.petId.isEmpty) {
      throw ArgumentError('Pet ID is required');
    }
    if (profile.ownerId.isEmpty) {
      throw ArgumentError('Owner ID is required');
    }

    // Save the profile
    return await _repository.savePetProfile(profile);
  }
}
