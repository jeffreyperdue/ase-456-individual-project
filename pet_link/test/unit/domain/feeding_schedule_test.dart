import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';

void main() {
  group('FeedingSchedule', () {
    test('copyWith updates selected fields and preserves others', () {
      final original = FeedingSchedule(
        id: '1',
        label: 'Breakfast',
        times: ['07:30'],
        daysOfWeek: [1, 2, 3],
        active: true,
        notes: 'Original',
      );

      final updated = original.copyWith(
        label: 'Updated',
        active: false,
      );

      expect(updated.id, original.id);
      expect(updated.label, 'Updated');
      expect(updated.times, original.times);
      expect(updated.daysOfWeek, original.daysOfWeek);
      expect(updated.active, isFalse);
      expect(updated.notes, original.notes);
    });

    test('toJson and fromJson round-trip correctly', () {
      final schedule = FeedingSchedule(
        id: '1',
        label: 'Dinner',
        times: ['18:00', '19:00'],
        daysOfWeek: [1, 3, 5],
        active: false,
        notes: 'Notes',
      );

      final json = schedule.toJson();
      final fromJson = FeedingSchedule.fromJson(json);

      expect(fromJson, equals(schedule));
    });

    test('shouldRunOnDay returns true when daysOfWeek is null (daily)', () {
      final schedule = FeedingSchedule(
        id: '1',
        label: 'Daily',
        times: ['07:00'],
        daysOfWeek: null,
      );

      expect(schedule.shouldRunOnDay(0), isTrue);
      expect(schedule.shouldRunOnDay(6), isTrue);
    });

    test('shouldRunOnDay respects daysOfWeek list', () {
      final schedule = FeedingSchedule(
        id: '1',
        label: 'Weekdays',
        times: ['07:00'],
        daysOfWeek: [1, 2, 3, 4, 5],
      );

      expect(schedule.shouldRunOnDay(0), isFalse); // Sunday
      expect(schedule.shouldRunOnDay(1), isTrue); // Monday
      expect(schedule.shouldRunOnDay(6), isFalse); // Saturday
    });

    test('description formats times and days correctly for daily', () {
      final schedule = FeedingSchedule(
        id: '1',
        label: 'Daily',
        times: ['07:00', '18:00'],
        daysOfWeek: null,
      );

      expect(schedule.description, '7:00 AM, 6:00 PM (daily)');
    });

    test('description formats times and days correctly for specific days', () {
      final schedule = FeedingSchedule(
        id: '1',
        label: 'Weekdays',
        times: ['07:00'],
        daysOfWeek: [1, 3, 5],
      );

      expect(schedule.description, '7:00 AM (Mon, Wed, Fri)');
    });
  });
}


