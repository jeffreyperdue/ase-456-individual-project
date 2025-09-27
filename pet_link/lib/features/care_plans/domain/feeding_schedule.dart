/// Represents a feeding schedule for a pet.
///
/// Example: "Breakfast at 7:30 AM daily" or "Dinner at 6:00 PM on weekends only"
class FeedingSchedule {
  final String id;
  final String? label; // "Breakfast", "Dinner", "Lunch"
  final List<String> times; // ["07:30", "18:00"] in 24-hour format
  final List<int>? daysOfWeek; // 0-6 (Sunday-Saturday), null means daily
  final bool active;
  final String? notes;

  const FeedingSchedule({
    required this.id,
    this.label,
    required this.times,
    this.daysOfWeek,
    this.active = true,
    this.notes,
  });

  /// Create a copy with updated fields.
  FeedingSchedule copyWith({
    String? id,
    String? label,
    List<String>? times,
    List<int>? daysOfWeek,
    bool? active,
    String? notes,
  }) {
    return FeedingSchedule(
      id: id ?? this.id,
      label: label ?? this.label,
      times: times ?? this.times,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      active: active ?? this.active,
      notes: notes ?? this.notes,
    );
  }

  /// Serialize to JSON for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'active': active,
      'notes': notes,
    };
  }

  /// Create from JSON (Firestore document).
  factory FeedingSchedule.fromJson(Map<String, dynamic> json) {
    return FeedingSchedule(
      id: json['id'] as String,
      label: json['label'] as String?,
      times: List<String>.from(json['times'] as List),
      daysOfWeek:
          json['daysOfWeek'] != null
              ? List<int>.from(json['daysOfWeek'] as List)
              : null,
      active: json['active'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }

  /// Check if this schedule should run on a given day of week.
  bool shouldRunOnDay(int dayOfWeek) {
    if (daysOfWeek == null) return true; // Daily schedule
    return daysOfWeek!.contains(dayOfWeek);
  }

  /// Get a human-readable description of the schedule.
  String get description {
    final timeStr = times.map((time) => _formatTime(time)).join(', ');
    final dayStr =
        daysOfWeek == null ? 'daily' : daysOfWeek!.map(_dayName).join(', ');

    return '$timeStr ($dayStr)';
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  String _dayName(int day) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[day];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedingSchedule &&
        other.id == id &&
        other.label == label &&
        other.times == times &&
        other.daysOfWeek == daysOfWeek &&
        other.active == active &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, label, times, daysOfWeek, active, notes);
  }

  @override
  String toString() {
    return 'FeedingSchedule(id: $id, label: $label, times: $times, daysOfWeek: $daysOfWeek, active: $active, notes: $notes)';
  }
}
