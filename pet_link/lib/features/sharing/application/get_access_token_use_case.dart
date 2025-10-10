import '../domain/access_token.dart';
import '../domain/access_token_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Use case for retrieving and validating access tokens.
class GetAccessTokenUseCase {
  final AccessTokenRepository _repository;

  GetAccessTokenUseCase(this._repository);

  /// Get an access token by ID and validate it.
  /// Returns null if token doesn't exist or is invalid.
  Future<AccessToken?> getValidToken(String tokenId) async {
    try {
      final token = await _repository.getAccessToken(tokenId);

      if (token == null) {
        return null;
      }

      // Check if token is valid (active and not expired)
      if (!token.isValid) {
        return null;
      }

      return token;
    } catch (e) {
      // Log error and return null for invalid tokens
      return null;
    }
  }

  /// Get all active access tokens for a specific pet.
  Future<List<AccessToken>> getTokensForPet(String petId) async {
    try {
      final tokens = await _repository.getAccessTokensForPet(petId);
      // Filter out expired tokens
      return tokens.where((token) => token.isValid).toList();
    } catch (e) {
      throw AccessTokenException('Failed to get tokens for pet: $e');
    }
  }

  /// Get all access tokens created by a specific user.
  Future<List<AccessToken>> getTokensByUser(String userId) async {
    try {
      return await _repository.getAccessTokensByUser(userId);
    } catch (e) {
      throw AccessTokenException('Failed to get tokens by user: $e');
    }
  }

  /// Check if a user has access to a specific pet with a given role.
  Future<bool> hasAccess(String petId, String userId, AccessRole role) async {
    try {
      final token = await _repository.getTokenByPetAndUser(petId, userId, role);
      return token?.isValid ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get token by pet and user combination.
  Future<AccessToken?> getTokenByPetAndUser(
    String petId,
    String userId,
    AccessRole role,
  ) async {
    try {
      return await _repository.getTokenByPetAndUser(petId, userId, role);
    } catch (e) {
      return null;
    }
  }
}
