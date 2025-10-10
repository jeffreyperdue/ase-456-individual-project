import '../domain/access_token.dart';
import '../application/get_access_token_use_case.dart';
import '../data/access_token_repository_impl.dart';

/// Service for checking user permissions and access rights.
class PermissionService {
  final GetAccessTokenUseCase _getTokenUseCase;
  final AccessTokenRepositoryImpl _tokenRepository;

  PermissionService(this._getTokenUseCase, this._tokenRepository);

  /// Check if a user can read pet information.
  Future<bool> canReadPet({
    required String petId,
    required String userId,
  }) async {
    try {
      // Check if user is the pet owner
      // TODO: Implement pet ownership check
      // For now, we'll assume all authenticated users can read pets they own

      // Check if user has valid token access
      final hasTokenAccess = await _hasValidTokenAccess(petId, userId);

      return hasTokenAccess;
    } catch (e) {
      return false;
    }
  }

  /// Check if a user can modify pet information.
  Future<bool> canModifyPet({
    required String petId,
    required String userId,
  }) async {
    try {
      // Only pet owners can modify pet information
      // TODO: Implement pet ownership check
      // For now, we'll assume all authenticated users can modify their own pets

      return true; // Simplified for now
    } catch (e) {
      return false;
    }
  }

  /// Check if a user can complete tasks for a pet.
  Future<bool> canCompleteTasks({
    required String petId,
    required String userId,
  }) async {
    try {
      // Check if user has sitter access
      final hasSitterAccess = await _hasSitterAccess(petId, userId);

      return hasSitterAccess;
    } catch (e) {
      return false;
    }
  }

  /// Check if a user can create access tokens for a pet.
  Future<bool> canCreateAccessTokens({
    required String petId,
    required String userId,
  }) async {
    try {
      // Only pet owners can create access tokens
      // TODO: Implement pet ownership check

      return true; // Simplified for now
    } catch (e) {
      return false;
    }
  }

  /// Get the access level for a user on a specific pet.
  Future<AccessLevel> getUserAccessLevel({
    required String petId,
    required String userId,
  }) async {
    try {
      // Check if user is the pet owner
      // TODO: Implement pet ownership check
      final isOwner = await _isPetOwner(petId, userId);
      if (isOwner) {
        return AccessLevel.owner;
      }

      // Check for token-based access
      final token = await _getValidTokenForUser(petId, userId);
      if (token != null) {
        switch (token.role) {
          case AccessRole.viewer:
            return AccessLevel.viewer;
          case AccessRole.sitter:
            return AccessLevel.sitter;
          case AccessRole.coCaretaker:
            return AccessLevel.coCaretaker;
        }
      }

      return AccessLevel.none;
    } catch (e) {
      return AccessLevel.none;
    }
  }

  /// Check if a user has any valid access to a pet.
  Future<bool> hasAnyAccess({
    required String petId,
    required String userId,
  }) async {
    final accessLevel = await getUserAccessLevel(petId: petId, userId: userId);
    return accessLevel != AccessLevel.none;
  }

  /// Get all active tokens for a user.
  Future<List<AccessToken>> getUserActiveTokens(String userId) async {
    try {
      final allTokens = await _tokenRepository.getAccessTokensByUser(userId);
      return allTokens.where((token) => token.isValid).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if a specific token is valid and active.
  Future<bool> isTokenValid(String tokenId) async {
    try {
      final token = await _getTokenUseCase.getValidToken(tokenId);
      return token != null;
    } catch (e) {
      return false;
    }
  }

  /// Private helper methods

  Future<bool> _hasValidTokenAccess(String petId, String userId) async {
    try {
      final tokens = await _tokenRepository.getAccessTokensByUser(userId);
      return tokens.any(
        (token) =>
            token.petId == petId && token.isValid && token.grantedTo == userId,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasSitterAccess(String petId, String userId) async {
    try {
      final tokens = await _tokenRepository.getAccessTokensByUser(userId);
      return tokens.any(
        (token) =>
            token.petId == petId &&
            token.isValid &&
            token.role == AccessRole.sitter &&
            token.grantedTo == userId,
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isPetOwner(String petId, String userId) async {
    // TODO: Implement pet ownership check
    // This would typically involve checking the pet's ownerId against the userId
    // For now, we'll return false to force token-based access
    return false;
  }

  Future<AccessToken?> _getValidTokenForUser(
    String petId,
    String userId,
  ) async {
    try {
      final tokens = await _tokenRepository.getAccessTokensByUser(userId);
      for (final token in tokens) {
        if (token.petId == petId &&
            token.isValid &&
            token.grantedTo == userId) {
          return token;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Access levels for users on pets.
enum AccessLevel {
  none, // No access
  viewer, // Read-only access
  sitter, // Can read and complete tasks
  coCaretaker, // Can read, complete tasks, and modify some data
  owner, // Full access
}

/// Extension to get display names for access levels.
extension AccessLevelExtension on AccessLevel {
  String get displayName {
    switch (this) {
      case AccessLevel.none:
        return 'No Access';
      case AccessLevel.viewer:
        return 'Viewer';
      case AccessLevel.sitter:
        return 'Pet Sitter';
      case AccessLevel.coCaretaker:
        return 'Co-Caretaker';
      case AccessLevel.owner:
        return 'Owner';
    }
  }

  String get description {
    switch (this) {
      case AccessLevel.none:
        return 'No access to this pet';
      case AccessLevel.viewer:
        return 'Can view pet information and care plans';
      case AccessLevel.sitter:
        return 'Can view information and complete care tasks';
      case AccessLevel.coCaretaker:
        return 'Can view and modify pet information';
      case AccessLevel.owner:
        return 'Full access to pet and all features';
    }
  }

  String get icon {
    switch (this) {
      case AccessLevel.none:
        return '🚫';
      case AccessLevel.viewer:
        return '👁️';
      case AccessLevel.sitter:
        return '🏠';
      case AccessLevel.coCaretaker:
        return '👥';
      case AccessLevel.owner:
        return '👑';
    }
  }

  bool get canRead {
    return this != AccessLevel.none;
  }

  bool get canCompleteTasks {
    return this == AccessLevel.sitter ||
        this == AccessLevel.coCaretaker ||
        this == AccessLevel.owner;
  }

  bool get canModify {
    return this == AccessLevel.coCaretaker || this == AccessLevel.owner;
  }

  bool get canCreateTokens {
    return this == AccessLevel.owner;
  }
}
