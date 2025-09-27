import '../domain/pet_profile.dart';
import '../domain/pet_profile_repository.dart';

/// Use case for retrieving pet profiles.
class GetPetProfileUseCase {
  GetPetProfileUseCase(this._repository);

  final PetProfileRepository _repository;

  /// Get a pet profile by pet ID.
  /// Returns null if no profile exists.
  Future<PetProfile?> execute(String petId) async {
    if (petId.isEmpty) {
      throw ArgumentError('Pet ID is required');
    }

    // For now, we'll use the stream-based approach in the provider
    // This method could be extended for one-time fetches if needed
    throw UnimplementedError('Use the provider for streaming pet profiles');
  }
}
