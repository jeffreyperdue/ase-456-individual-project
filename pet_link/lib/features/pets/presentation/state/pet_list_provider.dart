import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_link/features/pets/domain/pet.dart';
import 'package:pet_link/features/auth/presentation/state/auth_provider.dart';

/// Riverpod provider for pets list state management.
/// Syncs with Firestore for persistence.
class PetListNotifier extends StateNotifier<AsyncValue<List<Pet>>> {
  PetListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadPets();
  }

  final Ref _ref;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
  _petsSubscription;

  void _loadPets() {
    // Get current user ID
    final currentUser = _ref.read(currentUserDataProvider);
    if (currentUser == null) {
      state = const AsyncValue.data([]);
      return;
    }

    // Listen to Firestore changes and update state
    _petsSubscription = _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: currentUser.id)
        .snapshots()
        .listen(
          (snapshot) {
            final pets =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return Pet(
                    id: doc.id,
                    ownerId: data['ownerId'] ?? '',
                    name: data['name'] ?? '',
                    species: data['species'] ?? 'Unknown',
                    breed: data['breed'],
                    dateOfBirth: data['dateOfBirth']?.toDate(),
                    weightKg: data['weightKg']?.toDouble(),
                    heightCm: data['heightCm']?.toDouble(),
                    photoUrl: data['photoUrl'],
                    isLost: data['isLost'] ?? false,
                    createdAt: data['createdAt']?.toDate(),
                    updatedAt: data['updatedAt']?.toDate(),
                  );
                }).toList();
            state = AsyncValue.data(pets);
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  Future<void> add(Pet pet) async {
    try {
      // Save to Firestore - this will trigger the listener above
      await _firestore.collection('pets').doc(pet.id).set({
        'ownerId': pet.ownerId,
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'dateOfBirth': pet.dateOfBirth,
        'weightKg': pet.weightKg,
        'heightCm': pet.heightCm,
        'photoUrl': pet.photoUrl,
        'isLost': pet.isLost,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Pet saved to Firestore: ${pet.name}');
    } catch (e) {
      print('❌ Error saving pet: $e');
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _firestore.collection('pets').doc(id).delete();
      print('✅ Pet deleted from Firestore: $id');
    } catch (e) {
      print('❌ Error deleting pet: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _petsSubscription.cancel();
    super.dispose();
  }

  /// Convenience for MVP: create a quick dummy Pet so you can see the UI update.
  void addDummy() {
    final currentUser = _ref.read(currentUserDataProvider);
    if (currentUser == null) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    add(
      Pet(
        id: id,
        ownerId: currentUser.id,
        name: 'New Pet $id',
        species: 'Unknown',
      ),
    );
  }
}

/// Provider for the pets list state.
final petsProvider =
    StateNotifierProvider<PetListNotifier, AsyncValue<List<Pet>>>(
      (ref) => PetListNotifier(ref),
    );
