import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/care_plan.dart';
import '../domain/feeding_schedule.dart';
import '../domain/medication.dart';

/// State for the care plan form.
class CarePlanFormState {
  final String dietText;
  final List<FeedingSchedule> feedingSchedules;
  final List<Medication> medications;
  final bool isValid;
  final List<String> validationErrors;
  final bool isSubmitting;

  const CarePlanFormState({
    this.dietText = '',
    this.feedingSchedules = const [],
    this.medications = const [],
    this.isValid = false,
    this.validationErrors = const [],
    this.isSubmitting = false,
  });

  CarePlanFormState copyWith({
    String? dietText,
    List<FeedingSchedule>? feedingSchedules,
    List<Medication>? medications,
    bool? isValid,
    List<String>? validationErrors,
    bool? isSubmitting,
  }) {
    return CarePlanFormState(
      dietText: dietText ?? this.dietText,
      feedingSchedules: feedingSchedules ?? this.feedingSchedules,
      medications: medications ?? this.medications,
      isValid: isValid ?? this.isValid,
      validationErrors: validationErrors ?? this.validationErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// Create from an existing care plan.
  factory CarePlanFormState.fromCarePlan(CarePlan carePlan) {
    return CarePlanFormState(
      dietText: carePlan.dietText,
      feedingSchedules: List.from(carePlan.feedingSchedules),
      medications: List.from(carePlan.medications),
    );
  }

  /// Convert to a CarePlan object.
  CarePlan toCarePlan({
    required String id,
    required String petId,
    required String ownerId,
    String timezone = 'America/New_York',
  }) {
    return CarePlan(
      id: id,
      petId: petId,
      ownerId: ownerId,
      dietText: dietText,
      feedingSchedules: feedingSchedules,
      medications: medications,
      timezone: timezone,
    );
  }

  /// Get validation errors.
  List<String> getValidationErrors() {
    final errors = <String>[];

    // Diet text validation
    if (dietText.trim().isEmpty) {
      errors.add('Diet information is required');
    } else if (dietText.length > 2000) {
      errors.add('Diet information must be less than 2000 characters');
    }

    // Feeding schedules validation
    if (feedingSchedules.isEmpty) {
      errors.add('At least one feeding schedule is required');
    }

    for (final schedule in feedingSchedules) {
      if (schedule.times.isEmpty) {
        errors.add(
          'Feeding schedule "${schedule.label ?? 'Unnamed'}" must have at least one time',
        );
      }
    }

    // Medications validation (optional but if present, must be valid)
    for (final medication in medications) {
      if (medication.name.trim().isEmpty) {
        errors.add('Medication name is required');
      }
      if (medication.dosage.trim().isEmpty) {
        errors.add('Medication dosage is required');
      }
      if (medication.times.isEmpty) {
        errors.add(
          'Medication "${medication.name}" must have at least one time',
        );
      }
    }

    return errors;
  }

  /// Check if the form is valid.
  bool get isValidForm {
    final errors = getValidationErrors();
    return errors.isEmpty && dietText.trim().isNotEmpty;
  }
}

/// Notifier for managing care plan form state.
class CarePlanFormNotifier extends StateNotifier<CarePlanFormState> {
  CarePlanFormNotifier() : super(const CarePlanFormState());

  /// Update diet text.
  void updateDietText(String dietText) {
    state = state.copyWith(dietText: dietText);
    _validate();
  }

  /// Add a feeding schedule.
  void addFeedingSchedule(FeedingSchedule schedule) {
    final updatedSchedules = List<FeedingSchedule>.from(state.feedingSchedules);
    updatedSchedules.add(schedule);
    state = state.copyWith(feedingSchedules: updatedSchedules);
    _validate();
  }

  /// Update a feeding schedule.
  void updateFeedingSchedule(int index, FeedingSchedule schedule) {
    final updatedSchedules = List<FeedingSchedule>.from(state.feedingSchedules);
    if (index >= 0 && index < updatedSchedules.length) {
      updatedSchedules[index] = schedule;
      state = state.copyWith(feedingSchedules: updatedSchedules);
      _validate();
    }
  }

  /// Remove a feeding schedule.
  void removeFeedingSchedule(int index) {
    final updatedSchedules = List<FeedingSchedule>.from(state.feedingSchedules);
    if (index >= 0 && index < updatedSchedules.length) {
      updatedSchedules.removeAt(index);
      state = state.copyWith(feedingSchedules: updatedSchedules);
      _validate();
    }
  }

  /// Add a medication.
  void addMedication(Medication medication) {
    final updatedMedications = List<Medication>.from(state.medications);
    updatedMedications.add(medication);
    state = state.copyWith(medications: updatedMedications);
    _validate();
  }

  /// Update a medication.
  void updateMedication(int index, Medication medication) {
    final updatedMedications = List<Medication>.from(state.medications);
    if (index >= 0 && index < updatedMedications.length) {
      updatedMedications[index] = medication;
      state = state.copyWith(medications: updatedMedications);
      _validate();
    }
  }

  /// Remove a medication.
  void removeMedication(int index) {
    final updatedMedications = List<Medication>.from(state.medications);
    if (index >= 0 && index < updatedMedications.length) {
      updatedMedications.removeAt(index);
      state = state.copyWith(medications: updatedMedications);
      _validate();
    }
  }

  /// Load data from an existing care plan.
  void loadFromCarePlan(CarePlan carePlan) {
    state = CarePlanFormState.fromCarePlan(carePlan);
    _validate();
  }

  /// Reset the form.
  void reset() {
    state = const CarePlanFormState();
  }

  /// Set submitting state.
  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  /// Validate the form and update state.
  void _validate() {
    final errors = state.getValidationErrors();
    final isValid = errors.isEmpty && state.dietText.trim().isNotEmpty;

    state = state.copyWith(validationErrors: errors, isValid: isValid);
  }
}

/// Provider for care plan form state.
final carePlanFormProvider =
    StateNotifierProvider<CarePlanFormNotifier, CarePlanFormState>((ref) {
      return CarePlanFormNotifier();
    });
