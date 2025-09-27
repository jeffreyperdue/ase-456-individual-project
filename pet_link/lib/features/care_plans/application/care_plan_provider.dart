import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/care_plan.dart';
import '../domain/care_plan_repository.dart';
import '../services/care_scheduler.dart';
import 'providers.dart';
import 'package:pet_link/features/auth/presentation/state/auth_provider.dart';
import 'package:pet_link/features/auth/domain/user.dart' as app_user;

/// Riverpod provider for CarePlan state management.
///
/// Follows the same patterns as PetListNotifier for consistency.
class CarePlanNotifier extends StateNotifier<AsyncValue<CarePlan?>> {
  CarePlanNotifier(this._ref, this._repository, CareScheduler _scheduler)
    : super(const AsyncValue.loading()) {
    // Initial subscription will be set up when petId is provided
  }

  final Ref _ref;
  final CarePlanRepository _repository;

  StreamSubscription<CarePlan?>? _subscription;
  String? _currentPetId;
  String? _currentUserId;

  /// Watch a care plan for a specific pet.
  void watchCarePlanForPet(String petId) {
    _currentPetId = petId;

    // Get current auth state immediately
    final currentAuthState = _ref.read(authProvider);
    currentAuthState.when(
      data: (user) {
        _currentUserId = user?.id;
        if (_currentUserId != null) {
          _watchCarePlanStream();
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
          // If user changed, reset the care plan state
          if (_currentUserId != null && _currentUserId != userId) {
            _subscription?.cancel();
            state = const AsyncValue.loading();
            _currentUserId = userId;
            if (userId != null && _currentPetId != null) {
              _watchCarePlanStream();
            }
          } else {
            _currentUserId = userId;
            // If this is the first time setting the user ID, start the stream
            if (userId != null && _currentPetId != null) {
              _watchCarePlanStream();
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

  void _watchCarePlanStream() {
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
        .watchCarePlanForPet(_currentPetId!)
        .listen(
          (carePlan) => state = AsyncValue.data(carePlan),
          onError: (error, stack) => state = AsyncValue.error(error, stack),
        );
  }

  /// Create a new care plan for a pet.
  Future<void> createCarePlan(CarePlan carePlan) async {
    final saveUseCase = _ref.read(saveCarePlanUseCaseProvider);
    final notificationsEnabled = _ref.read(notificationsEnabledProvider);

    try {
      // Save the care plan
      await saveUseCase.execute(carePlan);

      // Schedule notifications if enabled
      if (notificationsEnabled) {
        final scheduleUseCase = _ref.read(scheduleRemindersUseCaseProvider);
        await scheduleUseCase.execute(carePlan);
      }

      // The stream will automatically update the state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update an existing care plan.
  Future<void> updateCarePlan(CarePlan carePlan) async {
    final saveUseCase = _ref.read(saveCarePlanUseCaseProvider);
    final notificationsEnabled = _ref.read(notificationsEnabledProvider);

    try {
      // Update the care plan
      await saveUseCase.execute(carePlan);

      // Reschedule notifications if enabled
      if (notificationsEnabled) {
        final scheduleUseCase = _ref.read(scheduleRemindersUseCaseProvider);
        await scheduleUseCase.execute(carePlan);
      }

      // The stream will automatically update the state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Delete a care plan.
  Future<void> deleteCarePlan(String carePlanId) async {
    final notificationsEnabled = _ref.read(notificationsEnabledProvider);

    try {
      // Cancel notifications first
      if (notificationsEnabled && _currentPetId != null) {
        final scheduleUseCase = _ref.read(scheduleRemindersUseCaseProvider);
        await scheduleUseCase.cancelForPet(_currentPetId!);
      }

      // Delete the care plan
      await _repository.deleteCarePlan(carePlanId);

      // The stream will automatically update the state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Refresh the current care plan.
  Future<void> refresh() async {
    if (_currentPetId != null) {
      watchCarePlanForPet(_currentPetId!);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for CarePlan state management.
final carePlanProvider =
    StateNotifierProvider<CarePlanNotifier, AsyncValue<CarePlan?>>((ref) {
      return CarePlanNotifier(
        ref,
        ref.read(carePlanRepositoryProvider),
        ref.read(careSchedulerProvider),
      );
    });

/// Provider to get care plan for a specific pet.
/// This provider takes a petId parameter.
final carePlanForPetProvider = StateNotifierProvider.family<
  CarePlanNotifier,
  AsyncValue<CarePlan?>,
  String
>((ref, petId) {
  final notifier = CarePlanNotifier(
    ref,
    ref.read(carePlanRepositoryProvider),
    ref.read(careSchedulerProvider),
  );

  // Start watching the care plan for this pet
  notifier.watchCarePlanForPet(petId);

  return notifier;
});
