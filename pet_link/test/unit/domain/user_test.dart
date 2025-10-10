import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/auth/domain/user.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('User Domain Model Tests', () {
    test('should create user with required fields', () {
      // Arrange & Act
      final user = TestDataFactory.createTestUser();

      // Assert
      expect(user.id, equals('test_user_id'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.roles, equals(['owner']));
      expect(user.createdAt, isNotNull);
    });

    test('should create user from Firebase Auth data', () {
      // Arrange
      const uid = 'firebase_uid';
      const email = 'firebase@example.com';
      const displayName = 'Firebase User';

      // Act
      final user = User.fromFirebaseAuth(
        uid: uid,
        email: email,
        displayName: displayName,
      );

      // Assert
      expect(user.id, equals(uid));
      expect(user.email, equals(email));
      expect(user.displayName, equals(displayName));
      expect(user.roles, equals(['owner']));
      expect(user.createdAt, isNotNull);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final user = TestDataFactory.createTestUser();

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], equals('test_user_id'));
      expect(json['email'], equals('test@example.com'));
      expect(json['displayName'], equals('Test User'));
      expect(json['roles'], equals(['owner']));
      expect(json['createdAt'], isNotNull);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'json_user_id',
        'email': 'json@example.com',
        'displayName': 'JSON User',
        'photoUrl': 'https://example.com/photo.jpg',
        'roles': ['owner'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals('json_user_id'));
      expect(user.email, equals('json@example.com'));
      expect(user.displayName, equals('JSON User'));
      expect(user.photoUrl, equals('https://example.com/photo.jpg'));
      expect(user.roles, equals(['owner']));
      expect(
        user.createdAt,
        equals(DateTime.parse('2024-01-01T00:00:00.000Z')),
      );
      expect(
        user.updatedAt,
        equals(DateTime.parse('2024-01-02T00:00:00.000Z')),
      );
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {'id': 'minimal_user_id', 'email': 'minimal@example.com'};

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals('minimal_user_id'));
      expect(user.email, equals('minimal@example.com'));
      expect(user.displayName, isNull);
      expect(user.photoUrl, isNull);
      expect(user.roles, equals(['owner'])); // Default value
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('should copy with updated fields', () {
      // Arrange
      final originalUser = TestDataFactory.createTestUser();

      // Act
      final updatedUser = originalUser.copyWith(
        displayName: 'Updated Name',
        photoUrl: 'https://example.com/new-photo.jpg',
        roles: ['owner', 'admin'],
      );

      // Assert
      expect(updatedUser.id, equals(originalUser.id));
      expect(updatedUser.email, equals(originalUser.email));
      expect(updatedUser.displayName, equals('Updated Name'));
      expect(updatedUser.photoUrl, equals('https://example.com/new-photo.jpg'));
      expect(updatedUser.roles, equals(['owner', 'admin']));
      expect(updatedUser.createdAt, equals(originalUser.createdAt));
    });

    test('should preserve original values when copyWith fields are null', () {
      // Arrange
      final originalUser = TestDataFactory.createTestUser();

      // Act
      final copiedUser = originalUser.copyWith();

      // Assert
      expect(copiedUser.id, equals(originalUser.id));
      expect(copiedUser.email, equals(originalUser.email));
      expect(copiedUser.displayName, equals(originalUser.displayName));
      expect(copiedUser.photoUrl, equals(originalUser.photoUrl));
      expect(copiedUser.roles, equals(originalUser.roles));
      expect(copiedUser.createdAt, equals(originalUser.createdAt));
      expect(copiedUser.updatedAt, equals(originalUser.updatedAt));
    });

    test('should support equality comparison', () {
      // Arrange
      final user1 = TestDataFactory.createTestUser();
      final user2 = TestDataFactory.createTestUser();
      final user3 = TestDataFactory.createTestUser(
        email: 'different@example.com',
      );

      // Act & Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should have meaningful toString representation', () {
      // Arrange
      final user = TestDataFactory.createTestUser();

      // Act
      final stringRepresentation = user.toString();

      // Assert
      expect(stringRepresentation, contains('test_user_id'));
      expect(stringRepresentation, contains('test@example.com'));
      expect(stringRepresentation, contains('Test User'));
    });

    test('should handle roles list equality correctly', () {
      // Arrange
      final user1 = TestDataFactory.createTestUser();
      final user2 = User(
        id: 'test_user_id',
        email: 'test@example.com',
        displayName: 'Test User',
        roles: ['owner'],
        createdAt: DateTime(2024, 1, 1),
      );

      // Act & Assert
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
