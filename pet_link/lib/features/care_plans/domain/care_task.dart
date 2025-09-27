/// Represents a specific care task that needs to be performed.
///
/// This is derived from a CarePlan and represents the next N tasks
/// that should be performed based on the current time and schedule.
class CareTask {
  final String id;
  final String petId;
  final String carePlanId;
  final CareTaskType type;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final String? notes;
  final bool completed;
  final DateTime? completedAt;

  const CareTask({
    required this.id,
    required this.petId,
    required this.carePlanId,
    required this.type,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.notes,
    this.completed = false,
    this.completedAt,
  });

  /// Create a copy with updated fields.
  CareTask copyWith({
    String? id,
    String? petId,
    String? carePlanId,
    CareTaskType? type,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? notes,
    bool? completed,
    DateTime? completedAt,
  }) {
    return CareTask(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      carePlanId: carePlanId ?? this.carePlanId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if this task is overdue.
  bool get isOverdue {
    return !completed && scheduledTime.isBefore(DateTime.now());
  }

  /// Check if this task is due soon (within the next 30 minutes).
  bool get isDueSoon {
    if (completed) return false;
    final now = DateTime.now();
    final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));
    return scheduledTime.isAfter(now) &&
        scheduledTime.isBefore(thirtyMinutesFromNow);
  }

  /// Get a human-readable time until the task is due.
  String get timeUntilDue {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.isNegative) {
      final overdue = now.difference(scheduledTime);
      if (overdue.inDays > 0) {
        return '${overdue.inDays} day${overdue.inDays == 1 ? '' : 's'} overdue';
      } else if (overdue.inHours > 0) {
        return '${overdue.inHours} hour${overdue.inHours == 1 ? '' : 's'} overdue';
      } else {
        return '${overdue.inMinutes} minute${overdue.inMinutes == 1 ? '' : 's'} overdue';
      }
    }

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else {
      return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    }
  }

  /// Get an icon for the task type.
  String get icon {
    switch (type) {
      case CareTaskType.feeding:
        return '🍽️';
      case CareTaskType.medication:
        return '💊';
      case CareTaskType.exercise:
        return '🏃';
      case CareTaskType.grooming:
        return '🛁';
      case CareTaskType.vet:
        return '🏥';
      case CareTaskType.other:
        return '📝';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CareTask &&
        other.id == id &&
        other.petId == petId &&
        other.carePlanId == carePlanId &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.scheduledTime == scheduledTime &&
        other.notes == notes &&
        other.completed == completed &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      petId,
      carePlanId,
      type,
      title,
      description,
      scheduledTime,
      notes,
      completed,
      completedAt,
    );
  }

  @override
  String toString() {
    return 'CareTask(id: $id, petId: $petId, type: $type, title: $title, scheduledTime: $scheduledTime, completed: $completed)';
  }
}

/// Types of care tasks that can be scheduled.
enum CareTaskType { feeding, medication, exercise, grooming, vet, other }

/// Extension to get display names for task types.
extension CareTaskTypeExtension on CareTaskType {
  String get displayName {
    switch (this) {
      case CareTaskType.feeding:
        return 'Feeding';
      case CareTaskType.medication:
        return 'Medication';
      case CareTaskType.exercise:
        return 'Exercise';
      case CareTaskType.grooming:
        return 'Grooming';
      case CareTaskType.vet:
        return 'Vet Appointment';
      case CareTaskType.other:
        return 'Other';
    }
  }
}
