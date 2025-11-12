/// Domain model for a lost pet report.
/// Regular Dart class with manual implementations for immutability and JSON serialization.
class LostReport {
  final String id;
  final String petId;
  final String ownerId;
  final DateTime createdAt;
  final String? lastSeenLocation;
  final String? notes;
  final String? posterUrl;

  const LostReport({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.createdAt,
    this.lastSeenLocation,
    this.notes,
    this.posterUrl,
  });

  /// Create a copy of this LostReport with the given fields replaced by the non-null parameter values.
  LostReport copyWith({
    String? id,
    String? petId,
    String? ownerId,
    DateTime? createdAt,
    String? lastSeenLocation,
    String? notes,
    String? posterUrl,
  }) {
    return LostReport(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      notes: notes ?? this.notes,
      posterUrl: posterUrl ?? this.posterUrl,
    );
  }

  /// Serializes this LostReport to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'lastSeenLocation': lastSeenLocation,
      'notes': notes,
      'posterUrl': posterUrl,
    };
  }

  /// Creates a LostReport from a JSON map.
  factory LostReport.fromJson(Map<String, dynamic> json) {
    return LostReport(
      id: json['id'] as String,
      petId: json['petId'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt'] as DateTime
              : DateTime.parse(json['createdAt'] as String))
          : DateTime.now(),
      lastSeenLocation: json['lastSeenLocation'] as String?,
      notes: json['notes'] as String?,
      posterUrl: json['posterUrl'] as String?,
    );
  }

  /// Creates a LostReport from a Firestore document.
  factory LostReport.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return LostReport(
      id: docId,
      petId: data['petId'] as String,
      ownerId: data['ownerId'] as String,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastSeenLocation: data['lastSeenLocation'] as String?,
      notes: data['notes'] as String?,
      posterUrl: data['posterUrl'] as String?,
    );
  }

  /// Converts this LostReport to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'lastSeenLocation': lastSeenLocation,
      'notes': notes,
      'posterUrl': posterUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LostReport &&
        other.id == id &&
        other.petId == petId &&
        other.ownerId == ownerId &&
        other.createdAt == createdAt &&
        other.lastSeenLocation == lastSeenLocation &&
        other.notes == notes &&
        other.posterUrl == posterUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      petId,
      ownerId,
      createdAt,
      lastSeenLocation,
      notes,
      posterUrl,
    );
  }

  @override
  String toString() {
    return 'LostReport(id: $id, petId: $petId, ownerId: $ownerId, createdAt: $createdAt, lastSeenLocation: $lastSeenLocation, notes: $notes, posterUrl: $posterUrl)';
  }
}



