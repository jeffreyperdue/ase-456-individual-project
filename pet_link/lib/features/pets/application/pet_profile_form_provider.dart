import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pet_profile.dart';

/// State class for the pet profile form.
class PetProfileFormState {
  final String? veterinarianContact;
  final String? emergencyContact;
  final String? insuranceInfo;
  final String? microchipId;
  final String? allergies;
  final String? chronicConditions;
  final String? vaccinationHistory;
  final String? lastCheckupDate;
  final String? currentMedications;
  final String? generalNotes;
  final List<String> tags;
  final bool isSubmitting;
  final String? errorMessage;

  const PetProfileFormState({
    this.veterinarianContact,
    this.emergencyContact,
    this.insuranceInfo,
    this.microchipId,
    this.allergies,
    this.chronicConditions,
    this.vaccinationHistory,
    this.lastCheckupDate,
    this.currentMedications,
    this.generalNotes,
    this.tags = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Create form state from existing PetProfile.
  factory PetProfileFormState.fromPetProfile(PetProfile profile) {
    return PetProfileFormState(
      veterinarianContact: profile.veterinarianContact,
      emergencyContact: profile.emergencyContact,
      insuranceInfo: profile.insuranceInfo,
      microchipId: profile.microchipId,
      allergies: profile.allergies,
      chronicConditions: profile.chronicConditions,
      vaccinationHistory: profile.vaccinationHistory,
      lastCheckupDate: profile.lastCheckupDate,
      currentMedications: profile.currentMedications,
      generalNotes: profile.generalNotes,
      tags: List<String>.from(profile.tags),
    );
  }

  /// Create a copy with updated fields.
  PetProfileFormState copyWith({
    String? veterinarianContact,
    String? emergencyContact,
    String? insuranceInfo,
    String? microchipId,
    String? allergies,
    String? chronicConditions,
    String? vaccinationHistory,
    String? lastCheckupDate,
    String? currentMedications,
    String? generalNotes,
    List<String>? tags,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PetProfileFormState(
      veterinarianContact: veterinarianContact ?? this.veterinarianContact,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      microchipId: microchipId ?? this.microchipId,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      vaccinationHistory: vaccinationHistory ?? this.vaccinationHistory,
      lastCheckupDate: lastCheckupDate ?? this.lastCheckupDate,
      currentMedications: currentMedications ?? this.currentMedications,
      generalNotes: generalNotes ?? this.generalNotes,
      tags: tags ?? this.tags,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Convert form state to PetProfile.
  PetProfile toPetProfile({
    required String id,
    required String petId,
    required String ownerId,
  }) {
    return PetProfile(
      id: id,
      petId: petId,
      ownerId: ownerId,
      veterinarianContact:
          veterinarianContact?.trim().isEmpty == true
              ? null
              : veterinarianContact?.trim(),
      emergencyContact:
          emergencyContact?.trim().isEmpty == true
              ? null
              : emergencyContact?.trim(),
      insuranceInfo:
          insuranceInfo?.trim().isEmpty == true ? null : insuranceInfo?.trim(),
      microchipId:
          microchipId?.trim().isEmpty == true ? null : microchipId?.trim(),
      allergies: allergies?.trim().isEmpty == true ? null : allergies?.trim(),
      chronicConditions:
          chronicConditions?.trim().isEmpty == true
              ? null
              : chronicConditions?.trim(),
      vaccinationHistory:
          vaccinationHistory?.trim().isEmpty == true
              ? null
              : vaccinationHistory?.trim(),
      lastCheckupDate:
          lastCheckupDate?.trim().isEmpty == true
              ? null
              : lastCheckupDate?.trim(),
      currentMedications:
          currentMedications?.trim().isEmpty == true
              ? null
              : currentMedications?.trim(),
      generalNotes:
          generalNotes?.trim().isEmpty == true ? null : generalNotes?.trim(),
      tags:
          tags
              .where((tag) => tag.trim().isNotEmpty)
              .map((tag) => tag.trim())
              .toList(),
    );
  }

  /// Whether the form has any data filled in.
  bool get hasAnyData {
    return veterinarianContact?.isNotEmpty == true ||
        emergencyContact?.isNotEmpty == true ||
        insuranceInfo?.isNotEmpty == true ||
        microchipId?.isNotEmpty == true ||
        allergies?.isNotEmpty == true ||
        chronicConditions?.isNotEmpty == true ||
        vaccinationHistory?.isNotEmpty == true ||
        lastCheckupDate?.isNotEmpty == true ||
        currentMedications?.isNotEmpty == true ||
        generalNotes?.isNotEmpty == true ||
        tags.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetProfileFormState &&
        other.veterinarianContact == veterinarianContact &&
        other.emergencyContact == emergencyContact &&
        other.insuranceInfo == insuranceInfo &&
        other.microchipId == microchipId &&
        other.allergies == allergies &&
        other.chronicConditions == chronicConditions &&
        other.vaccinationHistory == vaccinationHistory &&
        other.lastCheckupDate == lastCheckupDate &&
        other.currentMedications == currentMedications &&
        other.generalNotes == generalNotes &&
        _listEquals(other.tags, tags) &&
        other.isSubmitting == isSubmitting &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      veterinarianContact,
      emergencyContact,
      insuranceInfo,
      microchipId,
      allergies,
      chronicConditions,
      vaccinationHistory,
      lastCheckupDate,
      currentMedications,
      generalNotes,
      tags,
      isSubmitting,
      errorMessage,
    );
  }
}

/// Helper function to compare lists for equality.
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

/// Notifier for managing pet profile form state.
class PetProfileFormNotifier extends StateNotifier<PetProfileFormState> {
  PetProfileFormNotifier() : super(const PetProfileFormState());

  /// Initialize form with existing pet profile data.
  void initializeWithProfile(PetProfile? profile) {
    if (profile != null) {
      state = PetProfileFormState.fromPetProfile(profile);
    } else {
      state = const PetProfileFormState();
    }
  }

  /// Update veterinarian contact.
  void setVeterinarianContact(String? value) {
    state = state.copyWith(veterinarianContact: value);
  }

  /// Update emergency contact.
  void setEmergencyContact(String? value) {
    state = state.copyWith(emergencyContact: value);
  }

  /// Update insurance info.
  void setInsuranceInfo(String? value) {
    state = state.copyWith(insuranceInfo: value);
  }

  /// Update microchip ID.
  void setMicrochipId(String? value) {
    state = state.copyWith(microchipId: value);
  }

  /// Update allergies.
  void setAllergies(String? value) {
    state = state.copyWith(allergies: value);
  }

  /// Update chronic conditions.
  void setChronicConditions(String? value) {
    state = state.copyWith(chronicConditions: value);
  }

  /// Update vaccination history.
  void setVaccinationHistory(String? value) {
    state = state.copyWith(vaccinationHistory: value);
  }

  /// Update last checkup date.
  void setLastCheckupDate(String? value) {
    state = state.copyWith(lastCheckupDate: value);
  }

  /// Update current medications.
  void setCurrentMedications(String? value) {
    state = state.copyWith(currentMedications: value);
  }

  /// Update general notes.
  void setGeneralNotes(String? value) {
    state = state.copyWith(generalNotes: value);
  }

  /// Add a tag.
  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !state.tags.contains(trimmedTag)) {
      final updatedTags = List<String>.from(state.tags)..add(trimmedTag);
      state = state.copyWith(tags: updatedTags);
    }
  }

  /// Remove a tag.
  void removeTag(String tag) {
    final updatedTags = List<String>.from(state.tags)..remove(tag);
    state = state.copyWith(tags: updatedTags);
  }

  /// Set submitting state.
  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  /// Set error message.
  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}

/// Provider for pet profile form state.
final petProfileFormProvider =
    StateNotifierProvider<PetProfileFormNotifier, PetProfileFormState>((ref) {
      return PetProfileFormNotifier();
    });
