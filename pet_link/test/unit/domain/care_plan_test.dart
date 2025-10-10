import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('CarePlan Domain Model Tests', () {
    test('should create care plan with required fields', () {
      // Arrange & Act
      final carePlan = TestDataFactory.createTestCarePlan();

      // Assert
      expect(carePlan.id, equals('test_care_plan_id'));
      expect(carePlan.petId, equals('test_pet_id'));
      expect(carePlan.ownerId, equals('test_user_id'));
      expect(carePlan.dietText, equals('High-quality dry food twice daily'));
      expect(carePlan.feedingSchedules, hasLength(1));
      expect(carePlan.medications, hasLength(1));
      expect(carePlan.timezone, equals('America/New_York'));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final carePlan = TestDataFactory.createTestCarePlan();

      // Act
      final json = carePlan.toJson();

      // Assert
      expect(json['id'], equals('test_care_plan_id'));
      expect(json['petId'], equals('test_pet_id'));
      expect(json['ownerId'], equals('test_user_id'));
      expect(json['dietText'], equals('High-quality dry food twice daily'));
      expect(json['feedingSchedules'], isA<List>());
      expect(json['medications'], isA<List>());
      expect(json['timezone'], equals('America/New_York'));
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'json_care_plan_id',
        'petId': 'json_pet_id',
        'ownerId': 'json_owner_id',
        'dietText': 'Premium wet food three times daily',
        'feedingSchedules': [
          {
            'id': 'feeding_1',
            'label': 'Morning',
            'times': ['07:00'],
            'daysOfWeek': [1, 2, 3, 4, 5],
            'active': true,
            'notes': 'Morning feeding',
          },
        ],
        'medications': [
          {
            'id': 'med_1',
            'name': 'Heart Medicine',
            'dosage': '1 tablet',
            'times': ['08:00'],
            'daysOfWeek': null,
            'active': true,
            'withFood': true,
            'notes': 'With breakfast',
          },
        ],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
        'timezone': 'America/Los_Angeles',
      };

      // Act
      final carePlan = CarePlan.fromJson(json);

      // Assert
      expect(carePlan.id, equals('json_care_plan_id'));
      expect(carePlan.petId, equals('json_pet_id'));
      expect(carePlan.ownerId, equals('json_owner_id'));
      expect(carePlan.dietText, equals('Premium wet food three times daily'));
      expect(carePlan.feedingSchedules, hasLength(1));
      expect(carePlan.medications, hasLength(1));
      expect(carePlan.timezone, equals('America/Los_Angeles'));
    });

    test('should handle missing optional fields in JSON', () {
      // Arrange
      final json = {
        'id': 'minimal_care_plan_id',
        'petId': 'minimal_pet_id',
        'ownerId': 'minimal_owner_id',
        'dietText': 'Basic diet',
      };

      // Act
      final carePlan = CarePlan.fromJson(json);

      // Assert
      expect(carePlan.id, equals('minimal_care_plan_id'));
      expect(carePlan.petId, equals('minimal_pet_id'));
      expect(carePlan.ownerId, equals('minimal_owner_id'));
      expect(carePlan.dietText, equals('Basic diet'));
      expect(carePlan.feedingSchedules, isEmpty);
      expect(carePlan.medications, isEmpty);
      expect(carePlan.timezone, equals('America/New_York')); // Default value
    });

    test('should copy with updated fields', () {
      // Arrange
      final originalCarePlan = TestDataFactory.createTestCarePlan();

      // Act
      final updatedCarePlan = originalCarePlan.copyWith(
        dietText: 'Updated diet information',
        timezone: 'Europe/London',
      );

      // Assert
      expect(updatedCarePlan.id, equals(originalCarePlan.id));
      expect(updatedCarePlan.petId, equals(originalCarePlan.petId));
      expect(updatedCarePlan.ownerId, equals(originalCarePlan.ownerId));
      expect(updatedCarePlan.dietText, equals('Updated diet information'));
      expect(updatedCarePlan.timezone, equals('Europe/London'));
      expect(
        updatedCarePlan.feedingSchedules,
        equals(originalCarePlan.feedingSchedules),
      );
      expect(updatedCarePlan.medications, equals(originalCarePlan.medications));
    });

    test('should support equality comparison', () {
      // Arrange
      final carePlan1 = TestDataFactory.createTestCarePlan();
      final carePlan2 = TestDataFactory.createTestCarePlan();
      final carePlan3 = TestDataFactory.createTestCarePlan(
        dietText: 'Different diet',
      );

      // Act & Assert
      expect(carePlan1, equals(carePlan2));
      expect(carePlan1, isNot(equals(carePlan3)));
      expect(carePlan1.hashCode, equals(carePlan2.hashCode));
    });

    test('should identify active schedules correctly', () {
      // Arrange
      final activeFeeding = TestDataFactory.createTestFeedingSchedule(
        active: true,
      );
      final inactiveFeeding = TestDataFactory.createTestFeedingSchedule(
        active: false,
      );
      final activeMedication = TestDataFactory.createTestMedication(
        active: true,
      );
      final inactiveMedication = TestDataFactory.createTestMedication(
        active: false,
      );

      final carePlan = TestDataFactory.createTestCarePlan(
        feedingSchedules: [activeFeeding, inactiveFeeding],
        medications: [activeMedication, inactiveMedication],
      );

      // Act & Assert
      expect(carePlan.hasActiveSchedules, isTrue);
      expect(carePlan.activeFeedingSchedules, hasLength(1));
      expect(carePlan.activeFeedingSchedules.first, equals(activeFeeding));
      expect(carePlan.activeMedications, hasLength(1));
      expect(carePlan.activeMedications.first, equals(activeMedication));
    });

    test(
      'should return false for hasActiveSchedules when no active schedules',
      () {
        // Arrange
        final inactiveFeeding = TestDataFactory.createTestFeedingSchedule(
          active: false,
        );
        final inactiveMedication = TestDataFactory.createTestMedication(
          active: false,
        );

        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [inactiveFeeding],
          medications: [inactiveMedication],
        );

        // Act & Assert
        expect(carePlan.hasActiveSchedules, isFalse);
        expect(carePlan.activeFeedingSchedules, isEmpty);
        expect(carePlan.activeMedications, isEmpty);
      },
    );

    test('should generate correct summary', () {
      // Arrange
      final feeding1 = TestDataFactory.createTestFeedingSchedule(
        label: 'Morning',
        active: true,
      );
      final feeding2 = TestDataFactory.createTestFeedingSchedule(
        label: 'Evening',
        active: true,
      );
      final medication = TestDataFactory.createTestMedication(
        name: 'Vitamins',
        active: true,
      );

      final carePlan = TestDataFactory.createTestCarePlan(
        feedingSchedules: [feeding1, feeding2],
        medications: [medication],
      );

      // Act
      final summary = carePlan.summary;

      // Assert
      expect(summary, contains('2 feedings'));
      expect(summary, contains('1 medication'));
    });

    test('should generate correct summary for single items', () {
      // Arrange
      final feeding = TestDataFactory.createTestFeedingSchedule(
        label: 'Daily',
        active: true,
      );

      final carePlan = TestDataFactory.createTestCarePlan(
        feedingSchedules: [feeding],
        medications: [],
      );

      // Act
      final summary = carePlan.summary;

      // Assert
      expect(summary, equals('1 feeding'));
    });

    test(
      'should generate "No active schedules" summary when no active schedules',
      () {
        // Arrange
        final inactiveFeeding = TestDataFactory.createTestFeedingSchedule(
          active: false,
        );

        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [inactiveFeeding],
          medications: [],
        );

        // Act
        final summary = carePlan.summary;

        // Assert
        expect(summary, equals('No active schedules'));
      },
    );

    group('CarePlan Validation Tests', () {
      test('should validate successfully with valid data', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan();

        // Act
        final errors = carePlan.validate();

        // Assert
        expect(errors, isEmpty);
      });

      test('should fail validation with empty diet text', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan();
        final invalidCarePlan = carePlan.copyWith(dietText: '');

        // Act
        final errors = invalidCarePlan.validate();

        // Assert
        expect(errors, contains('Diet information is required'));
      });

      test('should fail validation with diet text too long', () {
        // Arrange
        final longDietText = 'a' * 2001; // 2001 characters
        final carePlan = TestDataFactory.createTestCarePlan();
        final invalidCarePlan = carePlan.copyWith(dietText: longDietText);

        // Act
        final errors = invalidCarePlan.validate();

        // Assert
        expect(
          errors,
          contains('Diet information must be less than 2000 characters'),
        );
      });

      test('should fail validation with no feeding schedules', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan();
        final invalidCarePlan = carePlan.copyWith(feedingSchedules: []);

        // Act
        final errors = invalidCarePlan.validate();

        // Assert
        expect(errors, contains('At least one feeding schedule is required'));
      });

      test('should fail validation with feeding schedule having no times', () {
        // Arrange
        final emptyFeedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: [],
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [emptyFeedingSchedule],
        );

        // Act
        final errors = carePlan.validate();

        // Assert
        expect(
          errors,
          contains(
            'Feeding schedule "Morning Feeding" must have at least one time',
          ),
        );
      });

      test(
        'should fail validation with invalid time format in feeding schedule',
        () {
          // Arrange
          final invalidFeedingSchedule =
              TestDataFactory.createTestFeedingSchedule(
                times: ['25:00'], // Invalid time
              );
          final carePlan = TestDataFactory.createTestCarePlan(
            feedingSchedules: [invalidFeedingSchedule],
          );

          // Act
          final errors = carePlan.validate();

          // Assert
          expect(
            errors,
            contains('Invalid time format in feeding schedule: 25:00'),
          );
        },
      );

      test(
        'should fail validation with invalid day of week in feeding schedule',
        () {
          // Arrange
          final invalidFeedingSchedule =
              TestDataFactory.createTestFeedingSchedule(
                daysOfWeek: [7], // Invalid day (should be 0-6)
              );
          final carePlan = TestDataFactory.createTestCarePlan(
            feedingSchedules: [invalidFeedingSchedule],
          );

          // Act
          final errors = carePlan.validate();

          // Assert
          expect(
            errors,
            contains('Invalid day of week in feeding schedule: 7'),
          );
        },
      );

      test('should fail validation with medication having empty name', () {
        // Arrange
        final invalidMedication = TestDataFactory.createTestMedication(
          name: '',
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          medications: [invalidMedication],
        );

        // Act
        final errors = carePlan.validate();

        // Assert
        expect(errors, contains('Medication name is required'));
      });

      test('should fail validation with medication having empty dosage', () {
        // Arrange
        final invalidMedication = TestDataFactory.createTestMedication(
          dosage: '',
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          medications: [invalidMedication],
        );

        // Act
        final errors = carePlan.validate();

        // Assert
        expect(errors, contains('Medication dosage is required'));
      });

      test('should fail validation with medication having no times', () {
        // Arrange
        final invalidMedication = TestDataFactory.createTestMedication(
          times: [],
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          medications: [invalidMedication],
        );

        // Act
        final errors = carePlan.validate();

        // Assert
        expect(
          errors,
          contains('Medication "Test Medication" must have at least one time'),
        );
      });

      test('should return multiple validation errors', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan();
        final invalidCarePlan = carePlan.copyWith(
          dietText: '', // Invalid
          feedingSchedules: [], // Invalid
          medications: [
            TestDataFactory.createTestMedication(name: ''), // Invalid
            TestDataFactory.createTestMedication(dosage: ''), // Invalid
          ],
        );

        // Act
        final errors = invalidCarePlan.validate();

        // Assert
        expect(errors, hasLength(4));
        expect(errors, contains('Diet information is required'));
        expect(errors, contains('At least one feeding schedule is required'));
        expect(errors, contains('Medication name is required'));
        expect(errors, contains('Medication dosage is required'));
      });
    });
  });
}
