import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pets/domain/pet.dart';
import '../../pets/presentation/state/pet_list_provider.dart';
import '../domain/care_plan.dart';
import 'care_plan_provider.dart';
import 'care_task_provider.dart';

/// Combined Pet and CarePlan data for UI consumption.
class PetWithPlan {
  final Pet pet;
  final CarePlan? carePlan;
  final CareTaskStats taskStats;
  final bool hasCarePlan;
  final bool hasActiveSchedules;

  const PetWithPlan({
    required this.pet,
    required this.carePlan,
    required this.taskStats,
    required this.hasCarePlan,
    required this.hasActiveSchedules,
  });

  /// Create from separate pet and care plan data.
  factory PetWithPlan.fromData(
    Pet pet,
    CarePlan? carePlan,
    CareTaskStats taskStats,
  ) {
    return PetWithPlan(
      pet: pet,
      carePlan: carePlan,
      taskStats: taskStats,
      hasCarePlan: carePlan != null,
      hasActiveSchedules: carePlan?.hasActiveSchedules ?? false,
    );
  }

  /// Get care plan summary for display.
  String get carePlanSummary {
    if (!hasCarePlan) return 'No care plan';
    return carePlan?.summary ?? 'No active schedules';
  }

  /// Check if there are urgent tasks.
  bool get hasUrgentTasks => taskStats.hasUrgentTasks;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetWithPlan &&
        other.pet == pet &&
        other.carePlan == carePlan &&
        other.taskStats == taskStats;
  }

  @override
  int get hashCode {
    return Object.hash(pet, carePlan, taskStats);
  }
}

/// Provider for a single PetWithPlan by pet ID.
final petWithPlanProvider = Provider.family<AsyncValue<PetWithPlan>, String>((
  ref,
  petId,
) {
  // Watch the pet from the pets list
  final petsAsync = ref.watch(petsProvider);
  final carePlanAsync = ref.watch(carePlanForPetProvider(petId));

  return petsAsync.when(
    data: (pets) {
      // Find the specific pet
      final pet = pets.firstWhere((p) => p.id == petId);

      return carePlanAsync.when(
        data: (carePlan) {
          final taskStats = ref.watch(careTaskStatsProvider(carePlan));
          final petWithPlan = PetWithPlan.fromData(pet, carePlan, taskStats);
          return AsyncValue.data(petWithPlan);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for all pets with their care plans.
final allPetsWithPlanProvider = Provider<AsyncValue<List<PetWithPlan>>>((ref) {
  final petsAsync = ref.watch(petsProvider);

  return petsAsync.when(
    data: (pets) {
      if (pets.isEmpty) {
        return const AsyncValue.data([]);
      }

      // Create PetWithPlan objects for each pet
      final petsWithPlan =
          pets.map((pet) {
            final carePlanAsync = ref.watch(carePlanForPetProvider(pet.id));

            return carePlanAsync.when(
              data: (carePlan) {
                final taskStats = ref.watch(careTaskStatsProvider(carePlan));
                return PetWithPlan.fromData(pet, carePlan, taskStats);
              },
              loading:
                  () => PetWithPlan.fromData(
                    pet,
                    null,
                    const CareTaskStats(
                      total: 0,
                      overdue: 0,
                      dueSoon: 0,
                      today: 0,
                    ),
                  ),
              error:
                  (error, stack) => PetWithPlan.fromData(
                    pet,
                    null,
                    const CareTaskStats(
                      total: 0,
                      overdue: 0,
                      dueSoon: 0,
                      today: 0,
                    ),
                  ),
            );
          }).toList();

      return AsyncValue.data(petsWithPlan);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for pets that have urgent care tasks.
final petsWithUrgentTasksProvider = Provider<List<PetWithPlan>>((ref) {
  final allPetsAsync = ref.watch(allPetsWithPlanProvider);

  return allPetsAsync.when(
    data: (petsWithPlan) {
      return petsWithPlan
          .where((petWithPlan) => petWithPlan.hasUrgentTasks)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for pets that don't have care plans yet.
final petsWithoutCarePlansProvider = Provider<List<Pet>>((ref) {
  final allPetsAsync = ref.watch(allPetsWithPlanProvider);

  return allPetsAsync.when(
    data: (petsWithPlan) {
      return petsWithPlan
          .where((petWithPlan) => !petWithPlan.hasCarePlan)
          .map((petWithPlan) => petWithPlan.pet)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
