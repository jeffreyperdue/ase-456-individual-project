import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('LostReport Domain Model Tests', () {
    test('should create lost report with required fields', () {
      // Arrange & Act
      final lostReport = TestDataFactory.createTestLostReport();

      // Assert
      expect(lostReport.id, equals('test_lost_report_id'));
      expect(lostReport.petId, equals('test_pet_id'));
      expect(lostReport.ownerId, equals('test_user_id'));
      expect(lostReport.createdAt, equals(DateTime(2024, 1, 15, 12, 0, 0)));
      expect(lostReport.lastSeenLocation, isNull);
      expect(lostReport.notes, isNull);
      expect(lostReport.posterUrl, isNull);
    });

    test('should create lost report with optional fields', () {
      // Arrange & Act
      final lostReport = LostReport(
        id: 'optional_lost_report_id',
        petId: 'optional_pet_id',
        ownerId: 'optional_owner_id',
        createdAt: DateTime(2024, 1, 20, 10, 0, 0),
        lastSeenLocation: 'Central Park',
        notes: 'Last seen near the pond',
        posterUrl: 'https://example.com/poster.png',
      );

      // Assert
      expect(lostReport.id, equals('optional_lost_report_id'));
      expect(lostReport.petId, equals('optional_pet_id'));
      expect(lostReport.ownerId, equals('optional_owner_id'));
      expect(lostReport.createdAt, equals(DateTime(2024, 1, 20, 10, 0, 0)));
      expect(lostReport.lastSeenLocation, equals('Central Park'));
      expect(lostReport.notes, equals('Last seen near the pond'));
      expect(lostReport.posterUrl, equals('https://example.com/poster.png'));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final lostReport = TestDataFactory.createTestLostReport(
        lastSeenLocation: 'Central Park',
        notes: 'Last seen near the pond',
        posterUrl: 'https://example.com/poster.png',
      );

      // Act
      final json = lostReport.toJson();

      // Assert
      expect(json['id'], equals('test_lost_report_id'));
      expect(json['petId'], equals('test_pet_id'));
      expect(json['ownerId'], equals('test_user_id'));
      expect(json['createdAt'], equals('2024-01-15T12:00:00.000'));
      expect(json['lastSeenLocation'], equals('Central Park'));
      expect(json['notes'], equals('Last seen near the pond'));
      expect(json['posterUrl'], equals('https://example.com/poster.png'));
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'json_lost_report_id',
        'petId': 'json_pet_id',
        'ownerId': 'json_owner_id',
        'createdAt': '2024-01-20T10:00:00.000Z',
        'lastSeenLocation': 'Central Park',
        'notes': 'Last seen near the pond',
        'posterUrl': 'https://example.com/poster.png',
      };

      // Act
      final lostReport = LostReport.fromJson(json);

      // Assert
      expect(lostReport.id, equals('json_lost_report_id'));
      expect(lostReport.petId, equals('json_pet_id'));
      expect(lostReport.ownerId, equals('json_owner_id'));
      expect(lostReport.createdAt, equals(DateTime.parse('2024-01-20T10:00:00.000Z')));
      expect(lostReport.lastSeenLocation, equals('Central Park'));
      expect(lostReport.notes, equals('Last seen near the pond'));
      expect(lostReport.posterUrl, equals('https://example.com/poster.png'));
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'id': 'minimal_lost_report_id',
        'petId': 'minimal_pet_id',
        'ownerId': 'minimal_owner_id',
        'createdAt': '2024-01-15T12:00:00.000Z',
      };

      // Act
      final lostReport = LostReport.fromJson(json);

      // Assert
      expect(lostReport.id, equals('minimal_lost_report_id'));
      expect(lostReport.petId, equals('minimal_pet_id'));
      expect(lostReport.ownerId, equals('minimal_owner_id'));
      expect(lostReport.createdAt, equals(DateTime.parse('2024-01-15T12:00:00.000Z')));
      expect(lostReport.lastSeenLocation, isNull);
      expect(lostReport.notes, isNull);
      expect(lostReport.posterUrl, isNull);
    });

    test('should copy with updated fields', () {
      // Arrange
      final originalReport = TestDataFactory.createTestLostReport();

      // Act
      final updatedReport = originalReport.copyWith(
        lastSeenLocation: 'Updated Location',
        notes: 'Updated notes',
        posterUrl: 'https://example.com/updated_poster.png',
      );

      // Assert
      expect(updatedReport.id, equals(originalReport.id));
      expect(updatedReport.petId, equals(originalReport.petId));
      expect(updatedReport.ownerId, equals(originalReport.ownerId));
      expect(updatedReport.createdAt, equals(originalReport.createdAt));
      expect(updatedReport.lastSeenLocation, equals('Updated Location'));
      expect(updatedReport.notes, equals('Updated notes'));
      expect(updatedReport.posterUrl, equals('https://example.com/updated_poster.png'));
    });

    test('should preserve original values when copyWith fields are null', () {
      // Arrange
      final originalReport = TestDataFactory.createTestLostReport(
        lastSeenLocation: 'Original Location',
        notes: 'Original notes',
      );

      // Act
      final copiedReport = originalReport.copyWith();

      // Assert
      expect(copiedReport.id, equals(originalReport.id));
      expect(copiedReport.petId, equals(originalReport.petId));
      expect(copiedReport.ownerId, equals(originalReport.ownerId));
      expect(copiedReport.createdAt, equals(originalReport.createdAt));
      expect(copiedReport.lastSeenLocation, equals(originalReport.lastSeenLocation));
      expect(copiedReport.notes, equals(originalReport.notes));
      expect(copiedReport.posterUrl, equals(originalReport.posterUrl));
    });

    test('should support equality comparison', () {
      // Arrange
      final report1 = TestDataFactory.createTestLostReport();
      final report2 = TestDataFactory.createTestLostReport();
      final report3 = TestDataFactory.createTestLostReport(
        id: 'different_id',
      );

      // Act & Assert
      expect(report1, equals(report2));
      expect(report1, isNot(equals(report3)));
      expect(report1.hashCode, equals(report2.hashCode));
    });

    test('should have meaningful toString representation', () {
      // Arrange
      final lostReport = TestDataFactory.createTestLostReport();

      // Act
      final stringRepresentation = lostReport.toString();

      // Assert
      expect(stringRepresentation, contains('test_lost_report_id'));
      expect(stringRepresentation, contains('test_pet_id'));
      expect(stringRepresentation, contains('test_user_id'));
    });

    test('should handle DateTime objects in fromJson', () {
      // Arrange
      final createdAt = DateTime(2024, 1, 20, 10, 0, 0);
      final json = {
        'id': 'datetime_lost_report_id',
        'petId': 'datetime_pet_id',
        'ownerId': 'datetime_owner_id',
        'createdAt': createdAt, // DateTime object instead of string
      };

      // Act
      final lostReport = LostReport.fromJson(json);

      // Assert
      expect(lostReport.createdAt, equals(createdAt));
    });

    test('should convert to Firestore format correctly', () {
      // Arrange
      final lostReport = TestDataFactory.createTestLostReport(
        lastSeenLocation: 'Central Park',
        notes: 'Last seen near the pond',
        posterUrl: 'https://example.com/poster.png',
      );

      // Act
      final firestoreData = lostReport.toFirestore();

      // Assert
      expect(firestoreData['petId'], equals('test_pet_id'));
      expect(firestoreData['ownerId'], equals('test_user_id'));
      expect(firestoreData['createdAt'], equals(DateTime(2024, 1, 15, 12, 0, 0)));
      expect(firestoreData['lastSeenLocation'], equals('Central Park'));
      expect(firestoreData['notes'], equals('Last seen near the pond'));
      expect(firestoreData['posterUrl'], equals('https://example.com/poster.png'));
      // Note: 'id' should not be in Firestore data (it's the document ID)
      expect(firestoreData.containsKey('id'), isFalse);
    });
  });
}




