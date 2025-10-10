import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'permission_service.dart';
import 'get_access_token_use_case.dart';
import '../data/access_token_repository_impl.dart';

/// Provider for the permission service.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  final repository = AccessTokenRepositoryImpl();
  final getTokenUseCase = GetAccessTokenUseCase(repository);
  return PermissionService(getTokenUseCase, repository);
});

/// Provider for checking if a user can read a specific pet.
final canReadPetProvider = FutureProvider.family<bool, PetAccessRequest>((
  ref,
  request,
) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.canReadPet(
    petId: request.petId,
    userId: request.userId,
  );
});

/// Provider for checking if a user can modify a specific pet.
final canModifyPetProvider = FutureProvider.family<bool, PetAccessRequest>((
  ref,
  request,
) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.canModifyPet(
    petId: request.petId,
    userId: request.userId,
  );
});

/// Provider for checking if a user can complete tasks for a specific pet.
final canCompleteTasksProvider = FutureProvider.family<bool, PetAccessRequest>((
  ref,
  request,
) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.canCompleteTasks(
    petId: request.petId,
    userId: request.userId,
  );
});

/// Provider for getting a user's access level for a specific pet.
final userAccessLevelProvider =
    FutureProvider.family<AccessLevel, PetAccessRequest>((ref, request) async {
      final permissionService = ref.watch(permissionServiceProvider);
      return await permissionService.getUserAccessLevel(
        petId: request.petId,
        userId: request.userId,
      );
    });

/// Provider for getting all active tokens for a user.
final userActiveTokensProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  userId,
) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.getUserActiveTokens(userId);
});

/// State notifier for managing permission checks.
class PermissionNotifier extends StateNotifier<AsyncValue<AccessLevel>> {
  final PermissionService _permissionService;

  PermissionNotifier(this._permissionService)
    : super(const AsyncValue.data(AccessLevel.none));

  /// Check access level for a user on a pet.
  Future<void> checkAccessLevel({
    required String petId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final accessLevel = await _permissionService.getUserAccessLevel(
        petId: petId,
        userId: userId,
      );

      state = AsyncValue.data(accessLevel);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Check if user can read pet.
  Future<bool> canReadPet({
    required String petId,
    required String userId,
  }) async {
    try {
      return await _permissionService.canReadPet(petId: petId, userId: userId);
    } catch (e) {
      return false;
    }
  }

  /// Check if user can modify pet.
  Future<bool> canModifyPet({
    required String petId,
    required String userId,
  }) async {
    try {
      return await _permissionService.canModifyPet(
        petId: petId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if user can complete tasks.
  Future<bool> canCompleteTasks({
    required String petId,
    required String userId,
  }) async {
    try {
      return await _permissionService.canCompleteTasks(
        petId: petId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Clear the current state.
  void clear() {
    state = const AsyncValue.data(AccessLevel.none);
  }
}

/// Provider for the permission notifier.
final permissionNotifierProvider =
    StateNotifierProvider<PermissionNotifier, AsyncValue<AccessLevel>>((ref) {
      final permissionService = ref.watch(permissionServiceProvider);
      return PermissionNotifier(permissionService);
    });

/// Request object for pet access checks.
class PetAccessRequest {
  final String petId;
  final String userId;

  const PetAccessRequest({required this.petId, required this.userId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetAccessRequest &&
        other.petId == petId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(petId, userId);

  @override
  String toString() => 'PetAccessRequest(petId: $petId, userId: $userId)';
}
