/// Domain model for access tokens that enable sharing of pet profiles.
///
/// Access tokens provide time-limited, role-based access to pet information
/// for scenarios like pet sitting, veterinary visits, or emergency situations.
class AccessToken {
  final String id;
  final String petId;
  final String grantedBy; // Owner's user ID
  final AccessRole role; // viewer, sitter, co-caretaker
  final DateTime expiresAt;
  final DateTime createdAt;
  final String? notes; // Optional notes for the handoff
  final bool isActive;
  final String?
  grantedTo; // Optional: specific user ID if granting to registered user
  final String? contactInfo; // Phone/email for non-registered users

  const AccessToken({
    required this.id,
    required this.petId,
    required this.grantedBy,
    required this.role,
    required this.expiresAt,
    required this.createdAt,
    this.notes,
    this.isActive = true,
    this.grantedTo,
    this.contactInfo,
  });

  /// Create a copy with updated fields.
  AccessToken copyWith({
    String? id,
    String? petId,
    String? grantedBy,
    AccessRole? role,
    DateTime? expiresAt,
    DateTime? createdAt,
    String? notes,
    bool? isActive,
    String? grantedTo,
    String? contactInfo,
  }) {
    return AccessToken(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      grantedBy: grantedBy ?? this.grantedBy,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      grantedTo: grantedTo ?? this.grantedTo,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  /// Check if this token is expired.
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if this token is valid (active and not expired).
  bool get isValid {
    return isActive && !isExpired;
  }

  /// Get time remaining until expiration as a human-readable string.
  String get timeUntilExpiration {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} remaining';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} remaining';
    }
  }

  /// Get a short description of the access level.
  String get accessDescription {
    switch (role) {
      case AccessRole.viewer:
        return 'Read-only access to pet information';
      case AccessRole.sitter:
        return 'Temporary access to view and complete care tasks';
      case AccessRole.coCaretaker:
        return 'Long-term shared access to pet information';
    }
  }

  /// Serialize to JSON for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'grantedBy': grantedBy,
      'role': role.name,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
      'grantedTo': grantedTo,
      'contactInfo': contactInfo,
    };
  }

  /// Create from JSON (Firestore document).
  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      id: json['id'] as String,
      petId: json['petId'] as String,
      grantedBy: json['grantedBy'] as String,
      role: AccessRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => AccessRole.viewer,
      ),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      grantedTo: json['grantedTo'] as String?,
      contactInfo: json['contactInfo'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessToken &&
        other.id == id &&
        other.petId == petId &&
        other.grantedBy == grantedBy &&
        other.role == role &&
        other.expiresAt == expiresAt &&
        other.createdAt == createdAt &&
        other.notes == notes &&
        other.isActive == isActive &&
        other.grantedTo == grantedTo &&
        other.contactInfo == contactInfo;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      petId,
      grantedBy,
      role,
      expiresAt,
      createdAt,
      notes,
      isActive,
      grantedTo,
      contactInfo,
    );
  }

  @override
  String toString() {
    return 'AccessToken(id: $id, petId: $petId, grantedBy: $grantedBy, role: $role, expiresAt: $expiresAt, createdAt: $createdAt, notes: $notes, isActive: $isActive, grantedTo: $grantedTo, contactInfo: $contactInfo)';
  }
}

/// Access roles that define what level of access is granted.
enum AccessRole {
  viewer, // Read-only access to pet information
  sitter, // Time-limited access with task completion capabilities
  coCaretaker, // Long-term shared access (future feature)
}

/// Extension to get display names and descriptions for access roles.
extension AccessRoleExtension on AccessRole {
  String get displayName {
    switch (this) {
      case AccessRole.viewer:
        return 'Viewer';
      case AccessRole.sitter:
        return 'Pet Sitter';
      case AccessRole.coCaretaker:
        return 'Co-Caretaker';
    }
  }

  String get description {
    switch (this) {
      case AccessRole.viewer:
        return 'Can view pet information and care plans';
      case AccessRole.sitter:
        return 'Can view information and mark care tasks as complete';
      case AccessRole.coCaretaker:
        return 'Can view and modify pet information (future feature)';
    }
  }

  String get icon {
    switch (this) {
      case AccessRole.viewer:
        return '👁️';
      case AccessRole.sitter:
        return '🏠';
      case AccessRole.coCaretaker:
        return '👥';
    }
  }
}
