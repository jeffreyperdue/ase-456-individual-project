import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/care_plan.dart';
import '../domain/care_plan_repository.dart';

/// Firestore implementation of CarePlanRepository.
///
/// Follows the same patterns as PetsRepository for consistency.
/// Uses the 'care_plans' collection in Firestore.
class CarePlanRepositoryImpl implements CarePlanRepository {
  CarePlanRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Stream a care plan for a specific pet.
  /// Returns null if no care plan exists for the pet.
  @override
  Stream<CarePlan?> watchCarePlanForPet(String petId) {
    return _firestore
        .collection('care_plans')
        .where('petId', isEqualTo: petId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          final doc = snapshot.docs.first;
          final data = doc.data();

          return CarePlan.fromJson({'id': doc.id, ...data});
        });
  }

  /// Get a specific care plan by ID.
  @override
  Future<CarePlan?> getCarePlan(String carePlanId) async {
    final doc = await _firestore.collection('care_plans').doc(carePlanId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return CarePlan.fromJson({'id': doc.id, ...data});
  }

  /// Create a new care plan.
  /// Throws an exception if a care plan already exists for the pet.
  @override
  Future<void> createCarePlan(CarePlan carePlan) async {
    // Check for existing care plan for this pet
    final existing =
        await _firestore
            .collection('care_plans')
            .where('petId', isEqualTo: carePlan.petId)
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Care plan already exists for pet ${carePlan.petId}');
    }

    // Create the care plan document
    await _firestore.collection('care_plans').doc(carePlan.id).set({
      'petId': carePlan.petId,
      'ownerId': carePlan.ownerId,
      'dietText': carePlan.dietText,
      'feedingSchedules':
          carePlan.feedingSchedules.map((s) => s.toJson()).toList(),
      'medications': carePlan.medications.map((m) => m.toJson()).toList(),
      'timezone': carePlan.timezone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing care plan.
  @override
  Future<void> updateCarePlan(
    String carePlanId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('care_plans').doc(carePlanId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a care plan.
  @override
  Future<void> deleteCarePlan(String carePlanId) async {
    await _firestore.collection('care_plans').doc(carePlanId).delete();
  }

  /// Check if a care plan exists for the given pet.
  @override
  Future<bool> carePlanExistsForPet(String petId) async {
    final snapshot =
        await _firestore
            .collection('care_plans')
            .where('petId', isEqualTo: petId)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get care plan ID for a pet (helper method).
  /// Returns null if no care plan exists.
  Future<String?> getCarePlanIdForPet(String petId) async {
    final snapshot =
        await _firestore
            .collection('care_plans')
            .where('petId', isEqualTo: petId)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }
}

