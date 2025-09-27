import '../domain/care_plan.dart';
import '../domain/care_plan_repository.dart';

/// Use case for retrieving care plans.
class GetCarePlanUseCase {
  final CarePlanRepository _repository;

  const GetCarePlanUseCase(this._repository);

  /// Get a care plan by ID.
  /// Returns null if not found.
  Future<CarePlan?> getCarePlan(String carePlanId) async {
    return await _repository.getCarePlan(carePlanId);
  }

  /// Get a care plan for a specific pet.
  /// Returns null if no care plan exists for the pet.
  Future<CarePlan?> getCarePlanForPet(String petId) async {
    final exists = await _repository.carePlanExistsForPet(petId);
    if (!exists) return null;

    // For now, we'll need to implement a way to get by petId
    // This might require a different repository method or query
    // For MVP, we can assume one care plan per pet and use a naming convention
    final carePlanId = '${petId}_care_plan';
    return await _repository.getCarePlan(carePlanId);
  }
}
