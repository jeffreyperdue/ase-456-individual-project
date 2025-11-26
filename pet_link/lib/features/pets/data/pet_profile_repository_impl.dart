import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petfolio/app/config.dart';
import '../domain/pet_profile.dart';
import '../domain/pet_profile_repository.dart';

/// Firestore implementation of PetProfileRepository.
class PetProfileRepositoryImpl implements PetProfileRepository {
  PetProfileRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Stream a pet profile for a specific pet.
  /// Returns null if no profile exists for the pet.
  @override
  Stream<PetProfile?> watchPetProfile(String petId) {
    return _firestore
        .collection(FirestoreCollections.petProfiles)
        .where('petId', isEqualTo: petId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          final doc = snapshot.docs.first;
          final data = doc.data();

          return PetProfile.fromJson({'id': doc.id, ...data});
        });
  }

  /// Save a pet profile (create or update).
  /// Returns the saved profile.
  @override
  Future<PetProfile> savePetProfile(PetProfile profile) async {
    final now = DateTime.now();
    final profileToSave = profile.copyWith(
      updatedAt: now,
      createdAt: profile.createdAt ?? now,
    );

    final profileData = profileToSave.toJson();
    // Remove id from data since it's the document ID
    profileData.remove('id');

    if (profile.id.isEmpty || profile.id == profile.petId) {
      // Create new profile
      final docRef =
          await _firestore.collection(FirestoreCollections.petProfiles).add(
                profileData,
              );

      return profileToSave.copyWith(id: docRef.id);
    } else {
      // Update existing profile
      await _firestore
          .collection(FirestoreCollections.petProfiles)
          .doc(profile.id)
          .set(profileData, SetOptions(merge: true));

      return profileToSave;
    }
  }

  /// Delete a pet profile.
  @override
  Future<void> deletePetProfile(String petId) async {
    final querySnapshot = await _firestore
        .collection(FirestoreCollections.petProfiles)
        .where('petId', isEqualTo: petId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
    }
  }
}
