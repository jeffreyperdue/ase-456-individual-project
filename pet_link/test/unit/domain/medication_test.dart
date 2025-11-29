import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';

void main() {
  group('Medication', () {
    test('copyWith updates selected fields and preserves others', () {
      final original = Medication(
        id: '1',
        name: 'Med',
        dosage: '5 mg',
        times: ['09:00'],
        daysOfWeek: [1, 2],
        withFood: true,
        notes: 'Note',
        active: true,
      );

      final updated = original.copyWith(
        name: 'Updated',
        active: false,
        withFood: false,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Updated');
      expect(updated.dosage, original.dosage);
      expect(updated.times, original.times);
      expect(updated.daysOfWeek, original.daysOfWeek);
      expect(updated.withFood, isFalse);
      expect(updated.notes, original.notes);
      expect(updated.active, isFalse);
    });

    test('toJson and fromJson round-trip correctly', () {
      final medication = Medication(
        id: '1',
        name: 'Heart Med',
        dosage: '1 tablet',
        times: ['09:00', '21:00'],
        daysOfWeek: [1, 3, 5],
        withFood: true,
        notes: 'Notes',
        active: false,
      );

      final json = medication.toJson();
      final fromJson = Medication.fromJson(json);

      expect(fromJson, equals(medication));
    });

    test('shouldRunOnDay returns true when daysOfWeek is null (daily)', () {
      final medication = Medication(
        id: '1',
        name: 'Daily',
        dosage: '1 tablet',
        times: ['09:00'],
        daysOfWeek: null,
      );

      expect(medication.shouldRunOnDay(0), isTrue);
      expect(medication.shouldRunOnDay(6), isTrue);
    });

    test('shouldRunOnDay respects daysOfWeek list', () {
      final medication = Medication(
        id: '1',
        name: 'Weekdays',
        dosage: '1 tablet',
        times: ['09:00'],
        daysOfWeek: [1, 2, 3, 4, 5],
      );

      expect(medication.shouldRunOnDay(0), isFalse);
      expect(medication.shouldRunOnDay(1), isTrue);
      expect(medication.shouldRunOnDay(6), isFalse);
    });

    test('description formats times, days, and withFood correctly', () {
      final medication = Medication(
        id: '1',
        name: 'Heart Med',
        dosage: '1 tablet',
        times: ['09:00', '21:00'],
        daysOfWeek: [1, 3, 5],
        withFood: true,
      );

      expect(
        medication.description,
        '1 tablet at 9:00 AM, 9:00 PM (Mon, Wed, Fri) with food',
      );
    });

    test('description omits withFood when false', () {
      final medication = Medication(
        id: '1',
        name: 'Med',
        dosage: '1 tablet',
        times: ['09:00'],
        daysOfWeek: null,
        withFood: false,
      );

      expect(
        medication.description,
        '1 tablet at 9:00 AM (daily)',
      );
    });
  });
}


