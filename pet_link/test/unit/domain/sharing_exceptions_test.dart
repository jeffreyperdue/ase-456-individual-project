import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/sharing/domain/sharing_exceptions.dart';

void main() {
  group('AccessTokenException', () {
    test('toString includes message and class name', () {
      const message = 'Something went wrong';
      final exception = AccessTokenException(message);

      expect(exception.toString(), 'AccessTokenException: $message');
    });
  });

  group('AccessTokenValidationException', () {
    test('toString includes message and class name', () {
      const message = 'Invalid token';
      final exception = AccessTokenValidationException(message);

      expect(
        exception.toString(),
        'AccessTokenValidationException: $message',
      );
    });
  });
}


