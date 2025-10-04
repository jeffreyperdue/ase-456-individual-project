import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';

/// Riverpod provider for pets list state management.
/// Syncs with Firestore for persistence.
class PetListNotifier extends StateNotifier<AsyncValue<List<Pet>>> {
  PetListNotifier(this._ref, this._repository)
    : super(const AsyncValue.loading()) {
    // Initial subscription
    _subscribe();
    // Re-subscribe whenever the authenticated user changes
    _ref.listen(currentUserDataProvider, (_, __) => _subscribe());
  }

  final Ref _ref;
  final PetsRepository _repository;

  StreamSubscription<List<Pet>>? _subscription;

  void _subscribe() {
    final currentUser = _ref.read(currentUserDataProvider);
    _subscription?.cancel();
    if (currentUser == null) {
      state = const AsyncValue.data([]);
      return;
    }
    _subscription = _repository
        .watchPetsForOwner(currentUser.id)
        .listen(
          (pets) => state = AsyncValue.data(pets),
          onError: (error, stack) => state = AsyncValue.error(error, stack),
        );
  }

  Future<void> add(Pet pet) async {
    await _repository.createPet(pet);
  }

  Future<void> update(String petId, Map<String, dynamic> updates) async {
    await _repository.updatePet(petId, updates);
  }

  Future<void> remove(String id) async {
    await _repository.deletePet(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
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
final petsRepositoryProvider = Provider<PetsRepository>((ref) {
  // A plain provider to share a single repository instance
  return PetsRepository();
});

final petsProvider =
    StateNotifierProvider<PetListNotifier, AsyncValue<List<Pet>>>(
      (ref) => PetListNotifier(ref, ref.read(petsRepositoryProvider)),
    );
