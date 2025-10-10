import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/services/time_utils.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('TimeUtils Tests', () {
    group('Time Formatting Tests', () {
      test('should format TimeOfDay to HH:mm string correctly', () {
        // Arrange
        final timeOfDay = TimeOfDay(hour: 14, minute: 30);

        // Act
        final formatted = TimeUtils.formatTimeOfDay(timeOfDay);

        // Assert
        expect(formatted, equals('14:30'));
      });

      test('should format TimeOfDay with single digit hour and minute', () {
        // Arrange
        final timeOfDay = TimeOfDay(hour: 7, minute: 5);

        // Act
        final formatted = TimeUtils.formatTimeOfDay(timeOfDay);

        // Assert
        expect(formatted, equals('07:05'));
      });

      test('should format time string for display in 12-hour format', () {
        // Test cases: [input, expected]
        final testCases = [
          ['00:00', '12:00 AM'],
          ['01:30', '1:30 AM'],
          ['11:45', '11:45 AM'],
          ['12:00', '12:00 PM'],
          ['13:15', '1:15 PM'],
          ['23:59', '11:59 PM'],
        ];

        for (final testCase in testCases) {
          // Act
          final formatted = TimeUtils.formatTimeForDisplay(
            testCase[0] as String,
          );

          // Assert
          expect(formatted, equals(testCase[1]));
        }
      });

      test('should return original string for invalid time format', () {
        // Arrange
        const invalidTime = 'invalid_time';

        // Act
        final formatted = TimeUtils.formatTimeForDisplay(invalidTime);

        // Assert
        expect(formatted, equals(invalidTime));
      });
    });

    group('Time Parsing Tests', () {
      test('should parse valid time string to TimeOfDay', () {
        // Test cases: [input, expectedHour, expectedMinute]
        final testCases = [
          ['00:00', 0, 0],
          ['07:30', 7, 30],
          ['12:45', 12, 45],
          ['23:59', 23, 59],
        ];

        for (final testCase in testCases) {
          // Act
          final timeOfDay = TimeUtils.parseTimeOfDay(testCase[0] as String);

          // Assert
          expect(timeOfDay, isNotNull);
          expect(timeOfDay!.hour, equals(testCase[1]));
          expect(timeOfDay.minute, equals(testCase[2]));
        }
      });

      test('should return null for invalid time formats', () {
        // Arrange
        final invalidTimes = [
          '25:00', // Hour out of range
          '12:60', // Minute out of range
          '12', // Missing minutes
          '12:5', // Single digit minute
          'abc:def', // Non-numeric
          '', // Empty string
          '12:30:45', // Too many parts
        ];

        for (final invalidTime in invalidTimes) {
          // Act
          final timeOfDay = TimeUtils.parseTimeOfDay(invalidTime);

          // Assert
          expect(
            timeOfDay,
            isNull,
            reason: 'Should return null for "$invalidTime"',
          );
        }
      });
    });

    group('Time Validation Tests', () {
      test('should validate correct time formats', () {
        // Arrange
        final validTimes = [
          '00:00',
          '07:30',
          '12:45',
          '23:59',
          '09:05', // Two digit hour
        ];

        for (final time in validTimes) {
          // Act
          final isValid = TimeUtils.isValidTimeFormat(time);

          // Assert
          expect(isValid, isTrue, reason: 'Should be valid: "$time"');
        }
      });

      test('should reject invalid time formats', () {
        // Arrange
        final invalidTimes = [
          '25:00', // Hour out of range
          '12:60', // Minute out of range
          '12', // Missing minutes
          '12:5', // Single digit minute
          'abc:def', // Non-numeric
          '', // Empty string
          '12:30:45', // Too many parts
          '1:5', // Single digit without leading zero
        ];

        for (final time in invalidTimes) {
          // Act
          final isValid = TimeUtils.isValidTimeFormat(time);

          // Assert
          expect(isValid, isFalse, reason: 'Should be invalid: "$time"');
        }
      });
    });

    group('Day Name Conversion Tests', () {
      test('should get day names correctly', () {
        // Act
        final dayNames = TimeUtils.getDayNames();

        // Assert
        expect(
          dayNames,
          equals([
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
          ]),
        );
      });

      test('should get short day names correctly', () {
        // Act
        final shortDayNames = TimeUtils.getShortDayNames();

        // Assert
        expect(
          shortDayNames,
          equals(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
        );
      });

      test('should convert day names to numbers correctly', () {
        // Arrange
        final dayNames = ['Monday', 'Wednesday', 'Friday'];

        // Act
        final dayNumbers = TimeUtils.dayNamesToNumbers(dayNames);

        // Assert
        expect(
          dayNumbers,
          equals([1, 3, 5]),
        ); // Monday=1, Wednesday=3, Friday=5
      });

      test('should filter out invalid day names', () {
        // Arrange
        final dayNames = ['Monday', 'InvalidDay', 'Friday'];

        // Act
        final dayNumbers = TimeUtils.dayNamesToNumbers(dayNames);

        // Assert
        expect(dayNumbers, equals([1, 5])); // Only valid days
      });

      test('should convert day numbers to names correctly', () {
        // Arrange
        final dayNumbers = [1, 3, 5]; // Monday, Wednesday, Friday

        // Act
        final dayNames = TimeUtils.dayNumbersToNames(dayNumbers);

        // Assert
        expect(dayNames, equals(['Monday', 'Wednesday', 'Friday']));
      });

      test('should filter out invalid day numbers', () {
        // Arrange
        final dayNumbers = [1, 7, 5, -1]; // Monday, Invalid, Friday, Invalid

        // Act
        final dayNames = TimeUtils.dayNumbersToNames(dayNumbers);

        // Assert
        expect(dayNames, equals(['Monday', 'Friday'])); // Only valid days
      });
    });

    group('Time Occurrence Tests', () {
      late MockClock mockClock;

      setUp(() {
        mockClock = MockClock();
      });

      test('should get next occurrence for daily schedule', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0)); // Monday 10:00 AM
        const timeString = '12:00'; // 12:00 PM

        // Act
        final nextOccurrence = TimeUtils.getNextOccurrence(
          timeString,
          null, // Daily schedule
          mockClock,
        );

        // Assert
        expect(
          nextOccurrence,
          equals(DateTime(2024, 1, 15, 12, 0)),
        ); // Same day 12:00 PM
      });

      test('should get next occurrence for tomorrow when time has passed', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 14, 0)); // Monday 2:00 PM
        const timeString = '12:00'; // 12:00 PM

        // Act
        final nextOccurrence = TimeUtils.getNextOccurrence(
          timeString,
          null, // Daily schedule
          mockClock,
        );

        // Assert
        expect(
          nextOccurrence,
          equals(DateTime(2024, 1, 16, 12, 0)),
        ); // Next day 12:00 PM
      });

      test('should get next occurrence for specific days of week', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0)); // Monday 10:00 AM
        const timeString = '12:00';
        const daysOfWeek = [1, 3, 5]; // Monday, Wednesday, Friday

        // Act
        final nextOccurrence = TimeUtils.getNextOccurrence(
          timeString,
          daysOfWeek,
          mockClock,
        );

        // Assert
        expect(
          nextOccurrence,
          equals(DateTime(2024, 1, 15, 12, 0)),
        ); // Same Monday 12:00 PM
      });

      test('should get next occurrence for next valid day', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 14, 0)); // Monday 2:00 PM
        const timeString = '12:00';
        const daysOfWeek = [1, 3, 5]; // Monday, Wednesday, Friday

        // Act
        final nextOccurrence = TimeUtils.getNextOccurrence(
          timeString,
          daysOfWeek,
          mockClock,
        );

        // Assert
        expect(
          nextOccurrence,
          equals(DateTime(2024, 1, 17, 12, 0)),
        ); // Wednesday 12:00 PM
      });

      test('should return null for invalid time format', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0));
        const invalidTime = '25:00';

        // Act
        final nextOccurrence = TimeUtils.getNextOccurrence(
          invalidTime,
          null,
          mockClock,
        );

        // Assert
        expect(nextOccurrence, isNull);
      });

      test('should get time until next occurrence', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0)); // Monday 10:00 AM
        const timeString = '12:00'; // 12:00 PM

        // Act
        final timeUntil = TimeUtils.getTimeUntilNext(
          timeString,
          null,
          mockClock,
        );

        // Assert
        expect(timeUntil, equals(Duration(hours: 2))); // 2 hours until 12:00 PM
      });

      test(
        'should return null for time until when next occurrence is null',
        () {
          // Arrange
          mockClock.setTime(DateTime(2024, 1, 15, 10, 0));
          const invalidTime = '25:00';

          // Act
          final timeUntil = TimeUtils.getTimeUntilNext(
            invalidTime,
            null,
            mockClock,
          );

          // Assert
          expect(timeUntil, isNull);
        },
      );
    });

    group('Duration Formatting Tests', () {
      test('should format duration in days', () {
        // Arrange
        final duration = Duration(days: 3, hours: 2);

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('3 days'));
      });

      test('should format duration for single day', () {
        // Arrange
        final duration = Duration(days: 1);

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('1 day'));
      });

      test('should format duration in hours', () {
        // Arrange
        final duration = Duration(hours: 5, minutes: 30);

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('5 hours'));
      });

      test('should format duration for single hour', () {
        // Arrange
        final duration = Duration(hours: 1);

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('1 hour'));
      });

      test('should format duration in minutes', () {
        // Arrange
        final duration = Duration(minutes: 45);

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('45 minutes'));
      });

      test('should format duration for single minute', () {
        // Arrange
        final duration = Duration(minutes: 1);

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('1 minute'));
      });

      test('should format zero duration as "now"', () {
        // Arrange
        final duration = Duration.zero;

        // Act
        final formatted = TimeUtils.formatDuration(duration);

        // Assert
        expect(formatted, equals('now'));
      });
    });

    group('Quick Add Chips Tests', () {
      test('should get quick add chips correctly', () {
        // Act
        final chips = TimeUtils.getQuickAddChips();

        // Assert
        expect(
          chips.keys,
          containsAll(['Morning', 'Lunch', 'Evening', 'Night']),
        );
        expect(chips['Morning'], equals(['07:00', '07:30', '08:00']));
        expect(chips['Lunch'], equals(['12:00', '12:30', '13:00']));
        expect(chips['Evening'], equals(['18:00', '18:30', '19:00']));
        expect(chips['Night'], equals(['20:00', '21:00', '22:00']));
      });
    });

    group('Suggested Times Tests', () {
      test('should get suggested times correctly', () {
        // Act
        final suggestedTimes = TimeUtils.getSuggestedTimes();

        // Assert
        expect(suggestedTimes, isNotEmpty);
        expect(
          suggestedTimes,
          containsAll([
            '06:00',
            '07:00',
            '08:00',
            '12:00',
            '18:00',
            '19:00',
            '22:00',
          ]),
        );

        // Verify all suggested times are valid
        for (final time in suggestedTimes) {
          expect(TimeUtils.isValidTimeFormat(time), isTrue);
        }
      });
    });
  });
}
