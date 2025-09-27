import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/state/auth_provider.dart';
import '../../auth/domain/user.dart' as app_user;
import '../domain/pet_profile.dart';
import '../domain/pet_profile_repository.dart';
import '../data/pet_profile_repository_impl.dart';
import 'save_pet_profile_use_case.dart';
import 'get_pet_profile_use_case.dart';

/// Provider for PetProfileRepository.
final petProfileRepositoryProvider = Provider<PetProfileRepository>((ref) {
  return PetProfileRepositoryImpl();
});

/// Provider for SavePetProfileUseCase.
final savePetProfileUseCaseProvider = Provider<SavePetProfileUseCase>((ref) {
  final repository = ref.read(petProfileRepositoryProvider);
  return SavePetProfileUseCase(repository);
});

/// Provider for GetPetProfileUseCase.
final getPetProfileUseCaseProvider = Provider<GetPetProfileUseCase>((ref) {
  final repository = ref.read(petProfileRepositoryProvider);
  return GetPetProfileUseCase(repository);
});

/// Riverpod provider for PetProfile state management.
class PetProfileNotifier extends StateNotifier<AsyncValue<PetProfile?>> {
  PetProfileNotifier(this._ref, this._repository)
    : super(const AsyncValue.loading()) {
    // Initial subscription will be set up when petId is provided
  }

  final Ref _ref;
  final PetProfileRepository _repository;

  StreamSubscription<PetProfile?>? _subscription;
  String? _currentPetId;
  String? _currentUserId;

  /// Watch a pet profile for a specific pet.
  void watchPetProfile(String petId) {
    _currentPetId = petId;

    // Get current auth state immediately
    final currentAuthState = _ref.read(authProvider);
    currentAuthState.when(
      data: (user) {
        _currentUserId = user?.id;
        if (_currentUserId != null) {
          _watchPetProfileStream();
        }
      },
      loading: () {
        // Will be handled by the listener
      },
      error: (_, __) {
        _currentUserId = null;
      },
    );

    // Watch auth state changes to reset when user changes
    _ref.listen(authProvider, (previous, next) {
      next.when(
        data: (user) {
          final userId = user?.id;
          // If user changed, reset the pet profile state
          if (_currentUserId != null && _currentUserId != userId) {
            _subscription?.cancel();
            state = const AsyncValue.loading();
            _currentUserId = userId;
            if (userId != null && _currentPetId != null) {
              _watchPetProfileStream();
            }
          } else {
            _currentUserId = userId;
            // If this is the first time setting the user ID, start the stream
            if (userId != null && _currentPetId != null) {
              _watchPetProfileStream();
            }
          }
        },
        loading: () {
          // Keep loading state while auth is loading
        },
        error: (_, __) {
          _subscription?.cancel();
          state = const AsyncValue.data(null);
          _currentUserId = null;
        },
      );
    });
  }

  void _watchPetProfileStream() {
    _subscription?.cancel();

    if (_currentPetId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    // If no user is logged in, return null
    if (_currentUserId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    _subscription = _repository
        .watchPetProfile(_currentPetId!)
        .listen(
          (petProfile) => state = AsyncValue.data(petProfile),
          onError: (error, stack) => state = AsyncValue.error(error, stack),
        );
  }

  /// Create a new pet profile.
  Future<void> createPetProfile(PetProfile petProfile) async {
    final saveUseCase = _ref.read(savePetProfileUseCaseProvider);

    try {
      state = const AsyncValue.loading();
      final savedProfile = await saveUseCase.execute(petProfile);
      state = AsyncValue.data(savedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update an existing pet profile.
  Future<void> updatePetProfile(PetProfile petProfile) async {
    final saveUseCase = _ref.read(savePetProfileUseCaseProvider);

    try {
      state = const AsyncValue.loading();
      final savedProfile = await saveUseCase.execute(petProfile);
      state = AsyncValue.data(savedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Delete a pet profile.
  Future<void> deletePetProfile() async {
    if (_currentPetId == null) return;

    try {
      await _repository.deletePetProfile(_currentPetId!);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Refresh the current pet profile.
  Future<void> refresh() async {
    if (_currentPetId != null) {
      watchPetProfile(_currentPetId!);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for PetProfile state management.
final petProfileProvider =
    StateNotifierProvider<PetProfileNotifier, AsyncValue<PetProfile?>>((ref) {
      return PetProfileNotifier(ref, ref.read(petProfileRepositoryProvider));
    });

/// Provider to get pet profile for a specific pet.
/// This provider takes a petId parameter.
final petProfileForPetProvider = StateNotifierProvider.family<
  PetProfileNotifier,
  AsyncValue<PetProfile?>,
  String
>((ref, petId) {
  final notifier = PetProfileNotifier(
    ref,
    ref.read(petProfileRepositoryProvider),
  );

  // Start watching the pet profile for this pet
  notifier.watchPetProfile(petId);

  return notifier;
});
