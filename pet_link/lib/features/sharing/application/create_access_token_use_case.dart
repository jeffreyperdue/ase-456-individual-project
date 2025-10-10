import '../domain/access_token.dart';
import '../domain/access_token_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Use case for creating access tokens for pet sharing.
class CreateAccessTokenUseCase {
  final AccessTokenRepository _repository;

  CreateAccessTokenUseCase(this._repository);

  /// Create a new access token with the specified parameters.
  ///
  /// [petId] - ID of the pet to share
  /// [grantedBy] - ID of the user creating the token (pet owner)
  /// [role] - Access role (viewer, sitter, coCaretaker)
  /// [expiresAt] - When the token should expire
  /// [notes] - Optional notes about the handoff
  /// [grantedTo] - Optional: specific user ID if granting to registered user
  /// [contactInfo] - Optional: phone/email for non-registered users
  Future<AccessToken> execute({
    required String petId,
    required String grantedBy,
    required AccessRole role,
    required DateTime expiresAt,
    String? notes,
    String? grantedTo,
    String? contactInfo,
  }) async {
    // Validate expiration date
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

    // Generate unique token ID
    final tokenId = _generateTokenId();

    // Create the access token
    final token = AccessToken(
      id: tokenId,
      petId: petId,
      grantedBy: grantedBy,
      role: role,
      expiresAt: expiresAt,
      createdAt: now,
      notes: notes,
      isActive: true,
      grantedTo: grantedTo,
      contactInfo: contactInfo,
    );

    return await _repository.createAccessToken(token);
  }

  /// Generate a unique token ID using timestamp and random string.
  String _generateTokenId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'token_${timestamp}_$random';
  }
}
