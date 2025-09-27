import 'feeding_schedule.dart';
import 'medication.dart';

/// Represents a complete care plan for a pet.
///
/// This is the main entity that contains all feeding schedules,
/// medications, and diet information for a pet.
class CarePlan {
  final String id;
  final String petId;
  final String ownerId;
  final String dietText;
  final List<FeedingSchedule> feedingSchedules;
  final List<Medication> medications;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String timezone; // e.g., "America/New_York"

  const CarePlan({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.dietText,
    required this.feedingSchedules,
    required this.medications,
    this.createdAt,
    this.updatedAt,
    this.timezone = 'America/New_York', // Default timezone
  });

  /// Create a copy with updated fields.
  CarePlan copyWith({
    String? id,
    String? petId,
    String? ownerId,
    String? dietText,
    List<FeedingSchedule>? feedingSchedules,
    List<Medication>? medications,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? timezone,
  }) {
    return CarePlan(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      dietText: dietText ?? this.dietText,
      feedingSchedules: feedingSchedules ?? this.feedingSchedules,
      medications: medications ?? this.medications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timezone: timezone ?? this.timezone,
    );
  }

  /// Serialize to JSON for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'ownerId': ownerId,
      'dietText': dietText,
      'feedingSchedules': feedingSchedules.map((s) => s.toJson()).toList(),
      'medications': medications.map((m) => m.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'timezone': timezone,
    };
  }

  /// Create from JSON (Firestore document).
  factory CarePlan.fromJson(Map<String, dynamic> json) {
    return CarePlan(
      id: json['id'] as String,
      petId: json['petId'] as String,
      ownerId: json['ownerId'] as String,
      dietText: json['dietText'] as String,
      feedingSchedules:
          (json['feedingSchedules'] as List?)
              ?.map((s) => FeedingSchedule.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      medications:
          (json['medications'] as List?)
              ?.map((m) => Medication.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
      timezone: json['timezone'] as String? ?? 'America/New_York',
    );
  }

  /// Check if this care plan has any active schedules.
  bool get hasActiveSchedules {
    return feedingSchedules.any((s) => s.active) ||
        medications.any((m) => m.active);
  }

  /// Get all active feeding schedules.
  List<FeedingSchedule> get activeFeedingSchedules {
    return feedingSchedules.where((s) => s.active).toList();
  }

  /// Get all active medications.
  List<Medication> get activeMedications {
    return medications.where((m) => m.active).toList();
  }

  /// Get a summary of the care plan.
  String get summary {
    final feedingCount = activeFeedingSchedules.length;
    final medicationCount = activeMedications.length;

    final parts = <String>[];
    if (feedingCount > 0) {
      parts.add('$feedingCount feeding${feedingCount == 1 ? '' : 's'}');
    }
    if (medicationCount > 0) {
      parts.add(
        '$medicationCount medication${medicationCount == 1 ? '' : 's'}',
      );
    }

    return parts.isEmpty ? 'No active schedules' : parts.join(', ');
  }

  /// Validate the care plan data.
  List<String> validate() {
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

      // Validate time format
      for (final time in schedule.times) {
        if (!_isValidTimeFormat(time)) {
          errors.add('Invalid time format in feeding schedule: $time');
        }
      }

      // Validate days of week
      if (schedule.daysOfWeek != null) {
        for (final day in schedule.daysOfWeek!) {
          if (day < 0 || day > 6) {
            errors.add('Invalid day of week in feeding schedule: $day');
          }
        }
      }
    }

    // Medications validation
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

      // Validate time format
      for (final time in medication.times) {
        if (!_isValidTimeFormat(time)) {
          errors.add(
            'Invalid time format in medication "${medication.name}": $time',
          );
        }
      }

      // Validate days of week
      if (medication.daysOfWeek != null) {
        for (final day in medication.daysOfWeek!) {
          if (day < 0 || day > 6) {
            errors.add(
              'Invalid day of week in medication "${medication.name}": $day',
            );
          }
        }
      }
    }

    return errors;
  }

  /// Check if a time string is in valid HH:mm format.
  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarePlan &&
        other.id == id &&
        other.petId == petId &&
        other.ownerId == ownerId &&
        other.dietText == dietText &&
        other.feedingSchedules == feedingSchedules &&
        other.medications == medications &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.timezone == timezone;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      petId,
      ownerId,
      dietText,
      feedingSchedules,
      medications,
      createdAt,
      updatedAt,
      timezone,
    );
  }

  @override
  String toString() {
    return 'CarePlan(id: $id, petId: $petId, ownerId: $ownerId, dietText: $dietText, feedingSchedules: $feedingSchedules, medications: $medications, createdAt: $createdAt, updatedAt: $updatedAt, timezone: $timezone)';
  }
}
