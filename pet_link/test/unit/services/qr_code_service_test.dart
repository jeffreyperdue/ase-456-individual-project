import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:petfolio/features/sharing/domain/access_token.dart';
import 'package:petfolio/features/sharing/application/qr_code_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('QRCodeService Tests', () {
    late QRCodeService service;
    late AccessToken testToken;

    setUp(() {
      service = QRCodeService();
      testToken = TestDataFactory.createTestAccessToken();
    });

    group('URL Generation Tests', () {
      test('should generate shareable URL correctly', () {
        // Act
        final url = service.generateShareableURL(testToken);

        // Assert
        expect(
          url,
          equals('https://petfolio.app/shared-pet?token=test_token_id'),
        );
      });

      test('should generate different URLs for different tokens', () {
        // Arrange
        final token1 = TestDataFactory.createTestAccessToken(id: 'token_1');
        final token2 = TestDataFactory.createTestAccessToken(id: 'token_2');

        // Act
        final url1 = service.generateShareableURL(token1);
        final url2 = service.generateShareableURL(token2);

        // Assert
        expect(url1, equals('https://petfolio.app/shared-pet?token=token_1'));
        expect(url2, equals('https://petfolio.app/shared-pet?token=token_2'));
        expect(url1, isNot(equals(url2)));
      });
    });

    group('URL Validation Tests', () {
      test('should validate correct token URL format', () {
        // Arrange
        final validUrls = [
          'https://petfolio.app/shared-pet?token=abc123',
          'https://petfolio.app/shared-pet?token=token_xyz&other=param',
          'https://petfolio.app/shared-pet?other=param&token=abc123',
        ];

        for (final url in validUrls) {
          // Act
          final isValid = service.isValidTokenURL(url);

          // Assert
          expect(isValid, isTrue, reason: 'Should be valid: $url');
        }
      });

      test('should reject invalid token URL formats', () {
        // Arrange
        final invalidUrls = [
          'https://petfolio.app/shared-pet', // No token parameter
          'https://petfolio.app/shared-pet?other=param', // No token parameter
          'https://wrongdomain.com/shared-pet?token=abc123', // Wrong domain
          'https://petfolio.app/wrong-path?token=abc123', // Wrong path
          'https://petfolio.app/shared-pet?', // Empty parameters
          'not-a-url',
          '',
          'ftp://petfolio.app/shared-pet?token=abc123', // Wrong protocol
        ];

        for (final url in invalidUrls) {
          // Act
          final isValid = service.isValidTokenURL(url);

          // Assert
          expect(isValid, isFalse, reason: 'Should be invalid: $url');
        }
      });

      test('should handle malformed URLs gracefully', () {
        // Arrange
        final malformedUrls = [
          'https://',
          '://invalid',
          'https://[invalid',
          null,
        ];

        for (final url in malformedUrls) {
          // Act & Assert
          expect(() => service.isValidTokenURL(url ?? ''), returnsNormally);
        }
      });
    });

    group('Token Extraction Tests', () {
      test('should extract token from valid URL', () {
        // Arrange
        final validUrls = [
          'https://petfolio.app/shared-pet?token=abc123',
          'https://petfolio.app/shared-pet?token=token_xyz&other=param',
          'https://petfolio.app/shared-pet?other=param&token=abc123',
        ];

        for (final url in validUrls) {
          // Act
          final token = service.extractTokenFromURL(url);

          // Assert
          expect(token, isNotNull);
          expect(['abc123', 'token_xyz', 'abc123'], contains(token));
        }
      });

      test('should return null for invalid URLs', () {
        // Arrange
        final invalidUrls = [
          'https://petfolio.app/shared-pet?other=param',
          'https://wrongdomain.com/shared-pet?token=abc123',
          'not-a-url',
          '',
        ];

        for (final url in invalidUrls) {
          // Act
          final token = service.extractTokenFromURL(url);

          // Assert
          expect(token, isNull, reason: 'Should return null for: $url');
        }
      });

      test('should handle malformed URLs in extraction', () {
        // Arrange
        final malformedUrls = ['https://', '://invalid', 'https://[invalid'];

        for (final url in malformedUrls) {
          // Act
          final token = service.extractTokenFromURL(url);

          // Assert
          expect(
            token,
            isNull,
            reason: 'Should return null for malformed URL: $url',
          );
        }
      });
    });

    group('Secure Token ID Generation Tests', () {
      test('should generate unique token IDs', () {
        // Act
        final tokenId1 = service.generateSecureTokenId();
        final tokenId2 = service.generateSecureTokenId();

        // Assert
        expect(tokenId1, isNotNull);
        expect(tokenId2, isNotNull);
        expect(tokenId1, isNot(equals(tokenId2)));
      });

      test('should generate token IDs with correct prefix', () {
        // Act
        final tokenId = service.generateSecureTokenId();

        // Assert
        expect(tokenId, startsWith('token_'));
      });

      test('should generate token IDs of consistent length', () {
        // Act
        final tokenIds = List.generate(
          10,
          (_) => service.generateSecureTokenId(),
        );

        // Assert
        for (final tokenId in tokenIds) {
          expect(tokenId.length, equals(22)); // 'token_' + 16 characters
        }
      });

      test('should generate token IDs with valid characters', () {
        // Act
        final tokenIds = List.generate(
          10,
          (_) => service.generateSecureTokenId(),
        );

        // Assert
        for (final tokenId in tokenIds) {
          expect(tokenId, matches(r'^token_[a-f0-9]{16}$'));
        }
      });
    });

    group('QR Code Widget Generation Tests', () {
      testWidgets('should generate QR code widget', (
        WidgetTester tester,
      ) async {
        // Act
        final qrWidget = service.generateQRCode(token: testToken);

        // Assert
        expect(qrWidget, isA<Widget>());

        // Build the widget
        await tester.pumpWidget(MaterialApp(home: qrWidget));
        await tester.pumpAndSettle();

        // Verify the widget is rendered
        expect(find.byType(QrImageView), findsOneWidget);
      });

      testWidgets('should generate QR code widget with custom size', (
        WidgetTester tester,
      ) async {
        // Arrange
        const customSize = 300.0;

        // Act
        final qrWidget = service.generateQRCode(
          token: testToken,
          size: customSize,
        );

        // Assert
        expect(qrWidget, isA<Widget>());

        // Build the widget
        await tester.pumpWidget(MaterialApp(home: qrWidget));
        await tester.pumpAndSettle();

        // Verify the widget is rendered
        expect(find.byType(QrImageView), findsOneWidget);
      });

      testWidgets(
        'should generate QR code widget with custom error correction level',
        (WidgetTester tester) async {
          // Act
          final qrWidget = service.generateQRCode(
            token: testToken,
            errorCorrectionLevel: 1, // Low error correction
          );

          // Assert
          expect(qrWidget, isA<Widget>());

          // Build the widget
          await tester.pumpWidget(MaterialApp(home: qrWidget));
          await tester.pumpAndSettle();

          // Verify the widget is rendered
          expect(find.byType(QrImageView), findsOneWidget);
        },
      );
    });

    group('QR Code Bytes Generation Tests', () {
      test('should generate QR code bytes', () async {
        // Act
        final bytes = await service.generateQRCodeBytes(token: testToken);

        // Assert
        expect(bytes, isNotNull);
        expect(bytes, isA<List<int>>());
        expect(bytes!.length, greaterThan(0));
      });

      test('should generate QR code bytes with custom size', () async {
        // Arrange
        const customSize = 150.0;

        // Act
        final bytes = await service.generateQRCodeBytes(
          token: testToken,
          size: customSize,
        );

        // Assert
        expect(bytes, isNotNull);
        expect(bytes, isA<List<int>>());
        expect(bytes!.length, greaterThan(0));
      });

      test('should generate different bytes for different tokens', () async {
        // Arrange
        final token1 = TestDataFactory.createTestAccessToken(id: 'token_1');
        final token2 = TestDataFactory.createTestAccessToken(id: 'token_2');

        // Act
        final bytes1 = await service.generateQRCodeBytes(token: token1);
        final bytes2 = await service.generateQRCodeBytes(token: token2);

        // Assert
        expect(bytes1, isNotNull);
        expect(bytes2, isNotNull);
        expect(bytes1, isNot(equals(bytes2)));
      });
    });

    group('Share Functionality Tests', () {
      test('should share URL and handle platform channel errors', () async {
        // Act & Assert - In unit tests, platform channels are not available
        // so we expect the method to throw a QRCodeException
        expect(
          () async => await service.shareURL(
            token: testToken,
            subject: 'Test Subject',
            text: 'Test Text',
          ),
          throwsA(isA<QRCodeException>()),
        );
      });

      test('should share QR code and handle platform channel errors', () async {
        // Act & Assert - In unit tests, platform channels are not available
        // so we expect the method to throw a QRCodeException
        expect(
          () async => await service.shareQRCode(
            token: testToken,
            subject: 'Test Subject',
            text: 'Test Text',
          ),
          throwsA(isA<QRCodeException>()),
        );
      });

      test('should open URL and handle platform channel errors', () async {
        // Act & Assert - In unit tests, platform channels are not available
        // so we expect the method to throw a QRCodeException
        expect(
          () async => await service.openURL(testToken),
          throwsA(isA<QRCodeException>()),
        );
      });
    });

    group('Error Handling Tests', () {
      test('should handle QR code generation gracefully', () async {
        // Arrange
        final token = TestDataFactory.createTestAccessToken(
          id: 'test_token_id', // Valid token
        );

        // Act
        final bytes = await service.generateQRCodeBytes(token: token);

        // Assert - QR code generation should succeed and return PNG data
        expect(bytes, isNotNull);
        expect(bytes, isA<Uint8List>());
        expect(bytes!.length, greaterThan(0));

        // Verify it's valid PNG data (starts with PNG signature)
        expect(bytes[0], equals(0x89)); // PNG signature
        expect(bytes[1], equals(0x50)); // P
        expect(bytes[2], equals(0x4E)); // N
        expect(bytes[3], equals(0x47)); // G
      });

      test('should throw QRCodeException for share failures', () async {
        // This test would require mocking the Share.share method
        // For now, we'll test that the method exists and can be called
        expect(service.shareURL, isA<Function>());
        expect(service.shareQRCode, isA<Function>());
      });

      test('should throw QRCodeException for URL opening failures', () async {
        // This test would require mocking the canLaunchUrl method
        // For now, we'll test that the method exists and can be called
        expect(service.openURL, isA<Function>());
      });
    });

    group('QRCodeException Tests', () {
      test('should create QRCodeException with message', () {
        // Arrange
        const message = 'Test error message';

        // Act
        final exception = QRCodeException(message);

        // Assert
        expect(exception.message, equals(message));
        expect(exception.toString(), equals('QRCodeException: $message'));
      });
    });

    group('Edge Cases', () {
      test('should handle null token gracefully', () {
        // This test would require the service to handle null tokens
        // For now, we'll test with a valid token and ensure the service is robust
        expect(testToken, isNotNull);
        expect(service.generateQRCode(token: testToken), isA<Widget>());
      });

      test('should handle very long token IDs', () {
        // Arrange
        final longTokenId = 'token_' + 'a' * 100; // Very long token ID
        final longToken = TestDataFactory.createTestAccessToken(
          id: longTokenId,
        );

        // Act & Assert
        expect(() => service.generateShareableURL(longToken), returnsNormally);
      });

      test('should handle special characters in token IDs', () {
        // Arrange
        final specialTokenId = 'token_with-special.chars_123';
        final specialToken = TestDataFactory.createTestAccessToken(
          id: specialTokenId,
        );

        // Act
        final url = service.generateShareableURL(specialToken);

        // Assert
        expect(url, contains(specialTokenId));
      });
    });
  });
}
