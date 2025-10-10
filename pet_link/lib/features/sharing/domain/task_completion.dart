/// Domain model for tracking task completions by sitters.
class TaskCompletion {
  final String id;
  final String petId;
  final String careTaskId;
  final String completedBy; // User ID who completed the task
  final DateTime completedAt;
  final String? notes; // Optional notes from the sitter
  final Map<String, dynamic>? additionalData; // For future extensions

  const TaskCompletion({
    required this.id,
    required this.petId,
    required this.careTaskId,
    required this.completedBy,
    required this.completedAt,
    this.notes,
    this.additionalData,
  });

  /// Create a copy with updated fields.
  TaskCompletion copyWith({
    String? id,
    String? petId,
    String? careTaskId,
    String? completedBy,
    DateTime? completedAt,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) {
    return TaskCompletion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      careTaskId: careTaskId ?? this.careTaskId,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Serialize to JSON for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'careTaskId': careTaskId,
      'completedBy': completedBy,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
      'additionalData': additionalData,
    };
  }

  /// Create from JSON (Firestore document).
  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      id: json['id'] as String,
      petId: json['petId'] as String,
      careTaskId: json['careTaskId'] as String,
      completedBy: json['completedBy'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCompletion &&
        other.id == id &&
        other.petId == petId &&
        other.careTaskId == careTaskId &&
        other.completedBy == completedBy &&
        other.completedAt == completedAt &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, petId, careTaskId, completedBy, completedAt, notes);
  }

  @override
  String toString() {
    return 'TaskCompletion(id: $id, petId: $petId, careTaskId: $careTaskId, completedBy: $completedBy, completedAt: $completedAt, notes: $notes)';
  }
}
