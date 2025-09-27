import 'care_plan.dart';

/// Repository interface for CarePlan operations.
///
/// This defines the contract for data access operations,
/// making it easy to test and potentially swap implementations.
abstract class CarePlanRepository {
  /// Stream all care plans for a specific pet.
  /// Returns empty stream if no care plan exists.
  Stream<CarePlan?> watchCarePlanForPet(String petId);

  /// Get a specific care plan by ID.
  Future<CarePlan?> getCarePlan(String carePlanId);

  /// Create a new care plan.
  /// Throws an exception if a care plan already exists for the pet.
  Future<void> createCarePlan(CarePlan carePlan);

  /// Update an existing care plan.
  Future<void> updateCarePlan(String carePlanId, Map<String, dynamic> updates);

  /// Delete a care plan.
  Future<void> deleteCarePlan(String carePlanId);

  /// Check if a care plan exists for the given pet.
  Future<bool> carePlanExistsForPet(String petId);
}
