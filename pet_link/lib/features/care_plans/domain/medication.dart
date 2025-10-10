/// Represents a medication schedule for a pet.
///
/// Example: "Heart medication: 5mg twice daily with food"
class Medication {
  final String id;
  final String name;
  final String dosage; // "5 mg", "1/2 tablet", "2 drops"
  final List<String> times; // ["09:00", "21:00"] in 24-hour format
  final List<int>? daysOfWeek; // 0-6 (Sunday-Saturday), null means daily
  final bool withFood; // Whether medication should be given with food
  final String? notes;
  final bool active;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    this.daysOfWeek,
    this.withFood = false,
    this.notes,
    this.active = true,
  });

  /// Create a copy with updated fields.
  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    List<String>? times,
    List<int>? daysOfWeek,
    bool? withFood,
    String? notes,
    bool? active,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      withFood: withFood ?? this.withFood,
      notes: notes ?? this.notes,
      active: active ?? this.active,
    );
  }

  /// Serialize to JSON for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'withFood': withFood,
      'notes': notes,
      'active': active,
    };
  }

  /// Create from JSON (Firestore document).
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      times: List<String>.from(json['times'] as List),
      daysOfWeek:
          json['daysOfWeek'] != null
              ? List<int>.from(json['daysOfWeek'] as List)
              : null,
      withFood: json['withFood'] as bool? ?? false,
      notes: json['notes'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  /// Check if this medication should be given on a given day of week.
  bool shouldRunOnDay(int dayOfWeek) {
    if (daysOfWeek == null) return true; // Daily medication
    return daysOfWeek!.contains(dayOfWeek);
  }

  /// Get a human-readable description of the medication schedule.
  String get description {
    final timeStr = times.map((time) => _formatTime(time)).join(', ');
    final dayStr =
        daysOfWeek == null ? 'daily' : daysOfWeek!.map(_dayName).join(', ');
    final foodStr = withFood ? ' with food' : '';

    return '$dosage at $timeStr ($dayStr)$foodStr';
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
    return other is Medication &&
        other.id == id &&
        other.name == name &&
        other.dosage == dosage &&
        _listEquals(other.times, times) &&
        other.daysOfWeek == daysOfWeek &&
        other.withFood == withFood &&
        other.notes == notes &&
        other.active == active;
  }

  /// Helper method to compare lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      dosage,
      Object.hashAll(times),
      daysOfWeek,
      withFood,
      notes,
      active,
    );
  }

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage, times: $times, daysOfWeek: $daysOfWeek, withFood: $withFood, notes: $notes, active: $active)';
  }
}
