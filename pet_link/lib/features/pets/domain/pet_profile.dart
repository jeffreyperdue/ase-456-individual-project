/// Domain model for enhanced pet profile information.
///
/// This model contains emergency contacts, medical history, and general notes
/// that complement the basic Pet model for handoff and sharing scenarios.
class PetProfile {
  final String id;
  final String petId;
  final String ownerId;

  // Emergency/Contact Information
  final String? veterinarianContact;
  final String? emergencyContact;
  final String? insuranceInfo;
  final String? microchipId;

  // Medical/Health Information
  final String? allergies;
  final String? chronicConditions;
  final String? vaccinationHistory;
  final String? lastCheckupDate;
  final String? currentMedications;

  // General Information
  final String? generalNotes;
  final List<String> tags; // e.g., ["senior", "special needs", "anxious"]

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PetProfile({
    required this.id,
    required this.petId,
    required this.ownerId,
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
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields.
  PetProfile copyWith({
    String? id,
    String? petId,
    String? ownerId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetProfile(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this PetProfile to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'ownerId': ownerId,
      'veterinarianContact': veterinarianContact,
      'emergencyContact': emergencyContact,
      'insuranceInfo': insuranceInfo,
      'microchipId': microchipId,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'vaccinationHistory': vaccinationHistory,
      'lastCheckupDate': lastCheckupDate,
      'currentMedications': currentMedications,
      'generalNotes': generalNotes,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a PetProfile from a JSON map.
  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'] as String,
      petId: json['petId'] as String,
      ownerId: json['ownerId'] as String,
      veterinarianContact: json['veterinarianContact'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      insuranceInfo: json['insuranceInfo'] as String?,
      microchipId: json['microchipId'] as String?,
      allergies: json['allergies'] as String?,
      chronicConditions: json['chronicConditions'] as String?,
      vaccinationHistory: json['vaccinationHistory'] as String?,
      lastCheckupDate: json['lastCheckupDate'] as String?,
      currentMedications: json['currentMedications'] as String?,
      generalNotes: json['generalNotes'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetProfile &&
        other.id == id &&
        other.petId == petId &&
        other.ownerId == ownerId &&
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
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      petId,
      ownerId,
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
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'PetProfile(id: $id, petId: $petId, ownerId: $ownerId, veterinarianContact: $veterinarianContact, emergencyContact: $emergencyContact, insuranceInfo: $insuranceInfo, microchipId: $microchipId, allergies: $allergies, chronicConditions: $chronicConditions, vaccinationHistory: $vaccinationHistory, lastCheckupDate: $lastCheckupDate, currentMedications: $currentMedications, generalNotes: $generalNotes, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
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
