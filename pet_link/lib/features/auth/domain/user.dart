/// Domain model for a user.
/// Regular Dart class with manual implementations for immutability and JSON serialization.
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.roles = const ['owner'], // Default role
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this User with the given fields replaced by the non-null parameter values.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'roles': roles,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? ['owner'],
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

  /// Creates a User from Firebase Auth UserData.
  factory User.fromFirebaseAuth({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    return User(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoURL,
      roles: ['owner'], // Default role for new users
      createdAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        _listEquals(other.roles, roles) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      displayName,
      photoUrl,
      Object.hashAll(roles),
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt)';
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
}
