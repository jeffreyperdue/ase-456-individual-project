import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pet.dart';
import '../domain/pet_profile.dart';
import '../presentation/state/pet_list_provider.dart';
import 'pet_profile_providers.dart';
import '../../care_plans/application/pet_with_plan_provider.dart';
import '../../care_plans/domain/care_plan.dart';
import '../../care_plans/application/care_task_provider.dart';

/// Combined data model that includes Pet, PetProfile, and CarePlan.
class PetWithDetails {
  final Pet pet;
  final PetProfile? profile;
  final CarePlan? carePlan;
  final CareTaskStats taskStats;

  const PetWithDetails({
    required this.pet,
    this.profile,
    this.carePlan,
    required this.taskStats,
  });

  /// Create PetWithDetails from individual data pieces.
  factory PetWithDetails.fromData(
    Pet pet,
    PetProfile? profile,
    CarePlan? carePlan,
    CareTaskStats taskStats,
  ) {
    return PetWithDetails(
      pet: pet,
      profile: profile,
      carePlan: carePlan,
      taskStats: taskStats,
    );
  }

  /// Whether this pet has a complete profile (has some profile data).
  bool get hasProfile => profile != null && _hasAnyProfileData;

  /// Whether this pet has any profile data filled in.
  bool get _hasAnyProfileData {
    if (profile == null) return false;

    return profile!.veterinarianContact?.isNotEmpty == true ||
        profile!.emergencyContact?.isNotEmpty == true ||
        profile!.insuranceInfo?.isNotEmpty == true ||
        profile!.microchipId?.isNotEmpty == true ||
        profile!.allergies?.isNotEmpty == true ||
        profile!.chronicConditions?.isNotEmpty == true ||
        profile!.vaccinationHistory?.isNotEmpty == true ||
        profile!.lastCheckupDate?.isNotEmpty == true ||
        profile!.currentMedications?.isNotEmpty == true ||
        profile!.generalNotes?.isNotEmpty == true ||
        profile!.tags.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetWithDetails &&
        other.pet == pet &&
        other.profile == profile &&
        other.carePlan == carePlan &&
        other.taskStats == taskStats;
  }

  @override
  int get hashCode {
    return Object.hash(pet, profile, carePlan, taskStats);
  }

  @override
  String toString() {
    return 'PetWithDetails(pet: $pet, profile: $profile, carePlan: $carePlan, taskStats: $taskStats)';
  }
}

/// Provider for a single pet with its profile and care plan details.
final petWithDetailsProvider = Provider.family<
  AsyncValue<PetWithDetails>,
  String
>((ref, petId) {
  final petAsync = ref.watch(petsProvider);
  final profileAsync = ref.watch(petProfileForPetProvider(petId));
  final petWithPlanAsync = ref.watch(petWithPlanProvider(petId));

  return petAsync.when(
    data: (pets) {
      final pet = pets.where((p) => p.id == petId).firstOrNull;
      if (pet == null) {
        return AsyncValue.error('Pet not found', StackTrace.current);
      }

      return profileAsync.when(
        data: (profile) {
          return petWithPlanAsync.when(
            data: (petWithPlan) {
              return AsyncValue.data(
                PetWithDetails.fromData(
                  pet,
                  profile,
                  petWithPlan.carePlan,
                  petWithPlan.taskStats,
                ),
              );
            },
            loading:
                () => AsyncValue.data(
                  PetWithDetails.fromData(
                    pet,
                    profile,
                    null,
                    CareTaskStats(total: 0, overdue: 0, dueSoon: 0, today: 0),
                  ),
                ),
            error:
                (error, stack) => AsyncValue.data(
                  PetWithDetails.fromData(
                    pet,
                    profile,
                    null,
                    CareTaskStats(total: 0, overdue: 0, dueSoon: 0, today: 0),
                  ),
                ),
          );
        },
        loading: () => AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for all pets with their profile and care plan details.
final allPetsWithDetailsProvider = Provider<AsyncValue<List<PetWithDetails>>>((
  ref,
) {
  final petsAsync = ref.watch(petsProvider);

  return petsAsync.when(
    data: (pets) {
      if (pets.isEmpty) {
        return const AsyncValue.data([]);
      }

      // Create PetWithDetails objects for each pet
      final petsWithDetails =
          pets.map((pet) {
            final profileAsync = ref.watch(petProfileForPetProvider(pet.id));
            final petWithPlanAsync = ref.watch(petWithPlanProvider(pet.id));

            return profileAsync.when(
              data: (profile) {
                return petWithPlanAsync.when(
                  data: (petWithPlan) {
                    return PetWithDetails.fromData(
                      pet,
                      profile,
                      petWithPlan.carePlan,
                      petWithPlan.taskStats,
                    );
                  },
                  loading:
                      () => PetWithDetails.fromData(
                        pet,
                        profile,
                        null,
                        CareTaskStats(
                          total: 0,
                          overdue: 0,
                          dueSoon: 0,
                          today: 0,
                        ),
                      ),
                  error:
                      (error, stack) => PetWithDetails.fromData(
                        pet,
                        profile,
                        null,
                        CareTaskStats(
                          total: 0,
                          overdue: 0,
                          dueSoon: 0,
                          today: 0,
                        ),
                      ),
                );
              },
              loading:
                  () => PetWithDetails.fromData(
                    pet,
                    null,
                    null,
                    CareTaskStats(total: 0, overdue: 0, dueSoon: 0, today: 0),
                  ),
              error:
                  (error, stack) => PetWithDetails.fromData(
                    pet,
                    null,
                    null,
                    CareTaskStats(total: 0, overdue: 0, dueSoon: 0, today: 0),
                  ),
            );
          }).toList();

      return AsyncValue.data(petsWithDetails);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
