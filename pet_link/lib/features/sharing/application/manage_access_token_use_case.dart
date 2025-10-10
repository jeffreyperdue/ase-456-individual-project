import '../domain/access_token_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Use case for managing access tokens (update, deactivate, delete).
class ManageAccessTokenUseCase {
  final AccessTokenRepository _repository;

  ManageAccessTokenUseCase(this._repository);

  /// Update an access token.
  /// Only allows updating notes, contact info, and expiration date.
  Future<void> updateToken({
    required String tokenId,
    String? notes,
    String? contactInfo,
    DateTime? expiresAt,
  }) async {
    try {
      final existingToken = await _repository.getAccessToken(tokenId);
      if (existingToken == null) {
        throw AccessTokenException('Token not found');
      }

      // Validate new expiration date if provided
      if (expiresAt != null) {
        final now = DateTime.now();
        if (expiresAt.isBefore(now)) {
          throw AccessTokenValidationException(
            'Expiration date must be in the future',
          );
        }

        // Validate minimum duration (at least 1 hour)
        final minimumDuration = now.add(const Duration(hours: 1));
        if (expiresAt.isBefore(minimumDuration)) {
          throw AccessTokenValidationException(
            'Token must be valid for at least 1 hour',
          );
        }

        // Validate maximum duration (no more than 30 days)
        final maximumDuration = now.add(const Duration(days: 30));
        if (expiresAt.isAfter(maximumDuration)) {
          throw AccessTokenValidationException(
            'Token cannot be valid for more than 30 days',
          );
        }
      }

      // Create updated token
      final updatedToken = existingToken.copyWith(
        notes: notes,
        contactInfo: contactInfo,
        expiresAt: expiresAt,
      );

      await _repository.updateAccessToken(updatedToken);
    } catch (e) {
      if (e is AccessTokenException || e is AccessTokenValidationException) {
        rethrow;
      }
      throw AccessTokenException('Failed to update token: $e');
    }
  }

  /// Deactivate an access token (soft delete).
  Future<void> deactivateToken(String tokenId) async {
    try {
      await _repository.deactivateAccessToken(tokenId);
    } catch (e) {
      throw AccessTokenException('Failed to deactivate token: $e');
    }
  }

  /// Delete an access token permanently.
  Future<void> deleteToken(String tokenId) async {
    try {
      await _repository.deleteAccessToken(tokenId);
    } catch (e) {
      throw AccessTokenException('Failed to delete token: $e');
    }
  }

  /// Extend the expiration date of a token.
  Future<void> extendToken(String tokenId, Duration extension) async {
    try {
      final existingToken = await _repository.getAccessToken(tokenId);
      if (existingToken == null) {
        throw AccessTokenException('Token not found');
      }

      final newExpiration = existingToken.expiresAt.add(extension);

      // Validate new expiration date
      final now = DateTime.now();
      if (newExpiration.isBefore(now)) {
        throw AccessTokenValidationException(
          'New expiration date must be in the future',
        );
      }

      // Validate maximum duration (no more than 30 days from now)
      final maximumDuration = now.add(const Duration(days: 30));
      if (newExpiration.isAfter(maximumDuration)) {
        throw AccessTokenValidationException(
          'Token cannot be valid for more than 30 days',
        );
      }

      final updatedToken = existingToken.copyWith(expiresAt: newExpiration);
      await _repository.updateAccessToken(updatedToken);
    } catch (e) {
      if (e is AccessTokenException || e is AccessTokenValidationException) {
        rethrow;
      }
      throw AccessTokenException('Failed to extend token: $e');
    }
  }

  /// Clean up expired tokens.
  Future<void> cleanupExpiredTokens() async {
    try {
      await _repository.deleteExpiredTokens();
    } catch (e) {
      throw AccessTokenException('Failed to cleanup expired tokens: $e');
    }
  }
}
