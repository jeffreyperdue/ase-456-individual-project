import '../domain/care_plan.dart';
import '../domain/care_plan_repository.dart';

/// Use case for saving a care plan.
///
/// This encapsulates the business logic for creating and updating care plans,
/// including validation and ensuring uniqueness per pet.
class SaveCarePlanUseCase {
  final CarePlanRepository _repository;

  const SaveCarePlanUseCase(this._repository);

  /// Save a care plan (create or update).
  ///
  /// Returns the saved care plan.
  /// Throws [CarePlanValidationException] if validation fails.
  /// Throws [DuplicateCarePlanException] if trying to create a second plan for a pet.
  Future<CarePlan> execute(CarePlan carePlan) async {
    // Validate the care plan
    final validationErrors = carePlan.validate();
    if (validationErrors.isNotEmpty) {
      throw CarePlanValidationException(validationErrors);
    }

    // Check if this is a new care plan
    final existing = await _repository.getCarePlan(carePlan.id);

    if (existing == null) {
      // Creating a new care plan - check for duplicates
      final existsForPet = await _repository.carePlanExistsForPet(
        carePlan.petId,
      );
      if (existsForPet) {
        throw DuplicateCarePlanException(carePlan.petId);
      }

      // Create new care plan
      await _repository.createCarePlan(carePlan);
    } else {
      // Updating existing care plan
      await _repository.updateCarePlan(carePlan.id, {
        'dietText': carePlan.dietText,
        'feedingSchedules':
            carePlan.feedingSchedules.map((s) => s.toJson()).toList(),
        'medications': carePlan.medications.map((m) => m.toJson()).toList(),
        'timezone': carePlan.timezone,
        'updatedAt': DateTime.now(),
      });
    }

    // Return the saved care plan
    return await _repository.getCarePlan(carePlan.id) ?? carePlan;
  }
}

/// Exception thrown when care plan validation fails.
class CarePlanValidationException implements Exception {
  final List<String> errors;

  const CarePlanValidationException(this.errors);

  @override
  String toString() => 'CarePlanValidationException: ${errors.join(', ')}';
}

/// Exception thrown when trying to create a duplicate care plan for a pet.
class DuplicateCarePlanException implements Exception {
  final String petId;

  const DuplicateCarePlanException(this.petId);

  @override
  String toString() =>
      'DuplicateCarePlanException: Care plan already exists for pet $petId';
}
