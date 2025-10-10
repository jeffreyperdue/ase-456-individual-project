import 'access_token.dart';

/// Repository interface for managing access tokens.
///
/// This repository handles CRUD operations for access tokens that enable
/// sharing of pet profiles with different access levels.
abstract class AccessTokenRepository {
  /// Create a new access token.
  /// Returns the created token with generated ID.
  Future<AccessToken> createAccessToken(AccessToken token);

  /// Get an access token by its ID.
  /// Returns null if not found.
  Future<AccessToken?> getAccessToken(String tokenId);

  /// Get all active access tokens for a specific pet.
  Future<List<AccessToken>> getAccessTokensForPet(String petId);

  /// Get all access tokens created by a specific user.
  Future<List<AccessToken>> getAccessTokensByUser(String userId);

  /// Update an access token.
  Future<void> updateAccessToken(AccessToken token);

  /// Delete an access token.
  Future<void> deleteAccessToken(String tokenId);

  /// Deactivate an access token (soft delete).
  Future<void> deactivateAccessToken(String tokenId);

  /// Get expired tokens for cleanup.
  Future<List<AccessToken>> getExpiredTokens();

  /// Delete expired tokens.
  Future<void> deleteExpiredTokens();

  /// Validate if a token is still valid (active and not expired).
  Future<bool> isTokenValid(String tokenId);

  /// Get token by pet ID and role for a specific user.
  /// Useful for checking if a user already has access to a pet.
  Future<AccessToken?> getTokenByPetAndUser(
    String petId,
    String userId,
    AccessRole role,
  );
}
