/// Exceptions for sharing feature operations.
class AccessTokenException implements Exception {
  final String message;
  AccessTokenException(this.message);

  @override
  String toString() => 'AccessTokenException: $message';
}

/// Exception for access token validation errors.
class AccessTokenValidationException implements Exception {
  final String message;
  AccessTokenValidationException(this.message);

  @override
  String toString() => 'AccessTokenValidationException: $message';
}
