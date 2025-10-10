import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/sharing/domain/access_token.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AccessToken Domain Model Tests', () {
    test('should create access token with required fields', () {
      // Arrange & Act
      final token = TestDataFactory.createTestAccessToken();

      // Assert
      expect(token.id, equals('test_token_id'));
      expect(token.petId, equals('test_pet_id'));
      expect(token.grantedBy, equals('test_user_id'));
      expect(token.role, equals(AccessRole.viewer));
      expect(token.isActive, isTrue);
      expect(token.notes, equals('Test access token'));
    });

    test('should create access token with all optional fields', () {
      // Arrange & Act
      final token = AccessToken(
        id: 'full_token_id',
        petId: 'full_pet_id',
        grantedBy: 'full_owner_id',
        role: AccessRole.sitter,
        expiresAt: DateTime(2024, 1, 22, 12, 0, 0),
        createdAt: DateTime(2024, 1, 15, 12, 0, 0),
        notes: 'Full token with all fields',
        isActive: false,
        grantedTo: 'specific_user_id',
        contactInfo: 'sitter@example.com',
      );

      // Assert
      expect(token.id, equals('full_token_id'));
      expect(token.petId, equals('full_pet_id'));
      expect(token.grantedBy, equals('full_owner_id'));
      expect(token.role, equals(AccessRole.sitter));
      expect(token.expiresAt, equals(DateTime(2024, 1, 22, 12, 0, 0)));
      expect(token.createdAt, equals(DateTime(2024, 1, 15, 12, 0, 0)));
      expect(token.notes, equals('Full token with all fields'));
      expect(token.isActive, isFalse);
      expect(token.grantedTo, equals('specific_user_id'));
      expect(token.contactInfo, equals('sitter@example.com'));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final token = TestDataFactory.createTestAccessToken();

      // Act
      final json = token.toJson();

      // Assert
      expect(json['id'], equals('test_token_id'));
      expect(json['petId'], equals('test_pet_id'));
      expect(json['grantedBy'], equals('test_user_id'));
      expect(json['role'], equals('viewer'));
      expect(json['expiresAt'], equals('2024-01-22T12:00:00.000'));
      expect(json['createdAt'], equals('2024-01-15T12:00:00.000'));
      expect(json['notes'], equals('Test access token'));
      expect(json['isActive'], isTrue);
      expect(json['grantedTo'], isNull);
      expect(json['contactInfo'], isNull);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'json_token_id',
        'petId': 'json_pet_id',
        'grantedBy': 'json_owner_id',
        'role': 'sitter',
        'expiresAt': '2024-01-25T18:00:00.000',
        'createdAt': '2024-01-18T09:00:00.000',
        'notes': 'JSON token',
        'isActive': false,
        'grantedTo': 'json_user_id',
        'contactInfo': 'json@example.com',
      };

      // Act
      final token = AccessToken.fromJson(json);

      // Assert
      expect(token.id, equals('json_token_id'));
      expect(token.petId, equals('json_pet_id'));
      expect(token.grantedBy, equals('json_owner_id'));
      expect(token.role, equals(AccessRole.sitter));
      expect(
        token.expiresAt,
        equals(DateTime.parse('2024-01-25T18:00:00.000')),
      );
      expect(
        token.createdAt,
        equals(DateTime.parse('2024-01-18T09:00:00.000')),
      );
      expect(token.notes, equals('JSON token'));
      expect(token.isActive, isFalse);
      expect(token.grantedTo, equals('json_user_id'));
      expect(token.contactInfo, equals('json@example.com'));
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'id': 'minimal_token_id',
        'petId': 'minimal_pet_id',
        'grantedBy': 'minimal_owner_id',
        'role': 'viewer',
        'expiresAt': '2024-01-22T12:00:00.000',
        'createdAt': '2024-01-15T12:00:00.000',
      };

      // Act
      final token = AccessToken.fromJson(json);

      // Assert
      expect(token.id, equals('minimal_token_id'));
      expect(token.petId, equals('minimal_pet_id'));
      expect(token.grantedBy, equals('minimal_owner_id'));
      expect(token.role, equals(AccessRole.viewer));
      expect(token.notes, isNull);
      expect(token.isActive, isTrue); // Default value
      expect(token.grantedTo, isNull);
      expect(token.contactInfo, isNull);
    });

    test('should copy with updated fields', () {
      // Arrange
      final originalToken = TestDataFactory.createTestAccessToken();

      // Act
      final updatedToken = originalToken.copyWith(
        role: AccessRole.sitter,
        notes: 'Updated notes',
        isActive: false,
      );

      // Assert
      expect(updatedToken.id, equals(originalToken.id));
      expect(updatedToken.petId, equals(originalToken.petId));
      expect(updatedToken.grantedBy, equals(originalToken.grantedBy));
      expect(updatedToken.role, equals(AccessRole.sitter));
      expect(updatedToken.notes, equals('Updated notes'));
      expect(updatedToken.isActive, isFalse);
      expect(updatedToken.expiresAt, equals(originalToken.expiresAt));
      expect(updatedToken.createdAt, equals(originalToken.createdAt));
    });

    test('should support equality comparison', () {
      // Arrange
      final token1 = TestDataFactory.createTestAccessToken();
      final token2 = TestDataFactory.createTestAccessToken();
      final token3 = TestDataFactory.createTestAccessToken(
        role: AccessRole.sitter,
      );

      // Act & Assert
      expect(token1, equals(token2));
      expect(token1, isNot(equals(token3)));
      expect(token1.hashCode, equals(token2.hashCode));
    });

    test('should have meaningful toString representation', () {
      // Arrange
      final token = TestDataFactory.createTestAccessToken();

      // Act
      final stringRepresentation = token.toString();

      // Assert
      expect(stringRepresentation, contains('test_token_id'));
      expect(stringRepresentation, contains('test_pet_id'));
      expect(stringRepresentation, contains('test_user_id'));
      expect(stringRepresentation, contains('viewer'));
    });
  });

  group('AccessToken Expiration Tests', () {
    late MockClock mockClock;

    setUp(() {
      mockClock = MockClock();
    });

    test('should identify expired token correctly', () {
      // Arrange
      final now = DateTime.now();
      final expiredToken = AccessToken(
        id: 'expired_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: DateTime(2024, 1, 14, 12, 0, 0), // Yesterday
        createdAt: DateTime(2024, 1, 10, 12, 0, 0),
      );

      // Act & Assert
      expect(expiredToken.isExpired, isTrue);
      expect(expiredToken.isValid, isFalse);
    });

    test('should identify valid token correctly', () {
      // Arrange
      final now = DateTime.now();
      final validToken = AccessToken(
        id: 'valid_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(const Duration(days: 1)), // Tomorrow
        createdAt: now.subtract(const Duration(days: 5)),
        isActive: true,
      );

      // Act & Assert
      expect(validToken.isExpired, isFalse);
      expect(validToken.isValid, isTrue);
    });

    test('should identify inactive token as invalid', () {
      // Arrange
      final now = DateTime.now();
      final inactiveToken = AccessToken(
        id: 'inactive_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(const Duration(days: 1)), // Tomorrow
        createdAt: now.subtract(const Duration(days: 5)),
        isActive: false,
      );

      // Act & Assert
      expect(inactiveToken.isExpired, isFalse);
      expect(inactiveToken.isValid, isFalse); // Invalid because inactive
    });

    test('should calculate time until expiration correctly', () {
      // Arrange
      final now = DateTime.now();
      final token = AccessToken(
        id: 'time_test_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(
          const Duration(days: 3, hours: 1),
        ), // 3 days and 1 hour from now
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Act
      final timeUntil = token.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('3 days remaining'));
    });

    test('should handle expired token time calculation', () {
      // Arrange
      final now = DateTime.now();
      final expiredToken = AccessToken(
        id: 'expired_time_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: DateTime(2024, 1, 14, 12, 0, 0), // Yesterday
        createdAt: DateTime(2024, 1, 10, 12, 0, 0),
      );

      // Act
      final timeUntil = expiredToken.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('Expired'));
    });

    test('should handle single day remaining', () {
      // Arrange
      final now = DateTime.now();
      final token = AccessToken(
        id: 'single_day_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(
          const Duration(days: 1, hours: 1),
        ), // Tomorrow + 1 hour
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Act
      final timeUntil = token.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('1 day remaining'));
    });

    test('should handle hours remaining', () {
      // Arrange
      final now = DateTime.now();
      final token = AccessToken(
        id: 'hours_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(
          const Duration(hours: 3, minutes: 30),
        ), // 3 hours and 30 minutes from now
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Act
      final timeUntil = token.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('3 hours remaining'));
    });

    test('should handle single hour remaining', () {
      // Arrange
      final now = DateTime.now();
      final token = AccessToken(
        id: 'single_hour_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(
          const Duration(hours: 1, minutes: 30),
        ), // 1 hour and 30 minutes from now
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Act
      final timeUntil = token.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('1 hour remaining'));
    });

    test('should handle minutes remaining', () {
      // Arrange
      final now = DateTime.now();
      final token = AccessToken(
        id: 'minutes_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(
          const Duration(minutes: 45, seconds: 30),
        ), // 45 minutes and 30 seconds from now
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Act
      final timeUntil = token.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('45 minutes remaining'));
    });

    test('should handle single minute remaining', () {
      // Arrange
      final now = DateTime.now();
      final token = AccessToken(
        id: 'single_minute_token',
        petId: 'test_pet',
        grantedBy: 'test_owner',
        role: AccessRole.viewer,
        expiresAt: now.add(
          const Duration(minutes: 1, seconds: 30),
        ), // 1 minute and 30 seconds from now
        createdAt: now.subtract(const Duration(days: 5)),
      );

      // Act
      final timeUntil = token.timeUntilExpiration;

      // Assert
      expect(timeUntil, equals('1 minute remaining'));
    });
  });

  group('AccessRole Tests', () {
    test('should have correct display names', () {
      expect(AccessRole.viewer.displayName, equals('Viewer'));
      expect(AccessRole.sitter.displayName, equals('Pet Sitter'));
      expect(AccessRole.coCaretaker.displayName, equals('Co-Caretaker'));
    });

    test('should have correct descriptions', () {
      expect(
        AccessRole.viewer.description,
        equals('Can view pet information and care plans'),
      );
      expect(
        AccessRole.sitter.description,
        equals('Can view information and mark care tasks as complete'),
      );
      expect(
        AccessRole.coCaretaker.description,
        equals('Can view and modify pet information (future feature)'),
      );
    });

    test('should have correct icons', () {
      expect(AccessRole.viewer.icon, equals('👁️'));
      expect(AccessRole.sitter.icon, equals('🏠'));
      expect(AccessRole.coCaretaker.icon, equals('👥'));
    });

    test('should provide correct access descriptions', () {
      final viewerToken = TestDataFactory.createTestAccessToken(
        role: AccessRole.viewer,
      );
      final sitterToken = TestDataFactory.createTestAccessToken(
        role: AccessRole.sitter,
      );
      final coCaretakerToken = TestDataFactory.createTestAccessToken(
        role: AccessRole.coCaretaker,
      );

      expect(
        viewerToken.accessDescription,
        equals('Read-only access to pet information'),
      );
      expect(
        sitterToken.accessDescription,
        equals('Temporary access to view and complete care tasks'),
      );
      expect(
        coCaretakerToken.accessDescription,
        equals('Long-term shared access to pet information'),
      );
    });
  });
}
