/// Domain model for a single pet.
/// Regular Dart class with manual implementations for immutability and JSON serialization.
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? breed;
  final DateTime? dateOfBirth;
  final double? weightKg;
  final double? heightCm;
  final String? photoUrl;
  final bool isLost;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    this.dateOfBirth,
    this.weightKg,
    this.heightCm,
    this.photoUrl,
    this.isLost = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this Pet with the given fields replaced by the non-null parameter values.
  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    DateTime? dateOfBirth,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
    bool? isLost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      photoUrl: photoUrl ?? this.photoUrl,
      isLost: isLost ?? this.isLost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this Pet to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'photoUrl': photoUrl,
      'isLost': isLost,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a Pet from a JSON map.
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      weightKg: json['weightKg'] as double?,
      heightCm: json['heightCm'] as double?,
      photoUrl: json['photoUrl'] as String?,
      isLost: json['isLost'] as bool? ?? false,
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
    return other is Pet &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.species == species &&
        other.breed == breed &&
        other.dateOfBirth == dateOfBirth &&
        other.weightKg == weightKg &&
        other.heightCm == heightCm &&
        other.photoUrl == photoUrl &&
        other.isLost == isLost &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      ownerId,
      name,
      species,
      breed,
      dateOfBirth,
      weightKg,
      heightCm,
      photoUrl,
      isLost,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Pet(id: $id, ownerId: $ownerId, name: $name, species: $species, breed: $breed, dateOfBirth: $dateOfBirth, weightKg: $weightKg, heightCm: $heightCm, photoUrl: $photoUrl, isLost: $isLost, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
