import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/application/care_plan_form_provider.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';

void main() {
  group('CarePlanFormState', () {
    test('getValidationErrors returns errors for empty form', () {
      const state = CarePlanFormState();

      final errors = state.getValidationErrors();

      expect(errors, isNotEmpty);
      expect(
        errors,
        contains('Diet information is required'),
      );
      expect(
        errors,
        contains('At least one feeding schedule is required'),
      );
    });

    test('isValidForm is true when form has valid data', () {
      const schedule = FeedingSchedule(
        id: 'feed1',
        label: 'Breakfast',
        times: ['07:00'],
      );
      const medication = Medication(
        id: 'med1',
        name: 'Med',
        dosage: '1 tablet',
        times: ['09:00'],
      );

      const state = CarePlanFormState(
        dietText: 'Some diet info',
        feedingSchedules: [schedule],
        medications: [medication],
      );

      expect(state.isValidForm, isTrue);
      expect(state.getValidationErrors(), isEmpty);
    });

    test('fromCarePlan populates state from CarePlan', () {
      const schedule = FeedingSchedule(
        id: 'feed1',
        label: 'Breakfast',
        times: ['07:00'],
      );
      const medication = Medication(
        id: 'med1',
        name: 'Med',
        dosage: '1 tablet',
        times: ['09:00'],
      );

      final carePlan = CarePlanFormState(
        dietText: 'Diet',
        feedingSchedules: const [schedule],
        medications: const [medication],
      ).toCarePlan(
        id: 'plan1',
        petId: 'pet1',
        ownerId: 'owner1',
      );

      final state = CarePlanFormState.fromCarePlan(carePlan);

      expect(state.dietText, carePlan.dietText);
      expect(state.feedingSchedules, carePlan.feedingSchedules);
      expect(state.medications, carePlan.medications);
    });
  });

  group('CarePlanFormNotifier', () {
    late CarePlanFormNotifier notifier;

    setUp(() {
      notifier = CarePlanFormNotifier();
    });

    test('updateDietText updates state and triggers validation', () {
      notifier.updateDietText('New diet');

      expect(notifier.state.dietText, 'New diet');
      expect(notifier.state.validationErrors, isNotEmpty);
    });

    test('addFeedingSchedule adds schedule and validates', () {
      const schedule = FeedingSchedule(
        id: 'feed1',
        label: 'Breakfast',
        times: ['07:00'],
      );

      notifier.addFeedingSchedule(schedule);

      expect(notifier.state.feedingSchedules, contains(schedule));
    });

    test('addMedication adds medication and validates', () {
      const medication = Medication(
        id: 'med1',
        name: 'Med',
        dosage: '1 tablet',
        times: ['09:00'],
      );

      notifier.addMedication(medication);

      expect(notifier.state.medications, contains(medication));
    });

    test('reset restores initial state', () {
      notifier.updateDietText('Diet');
      notifier.reset();

      expect(notifier.state.dietText, '');
      expect(notifier.state.feedingSchedules, isEmpty);
      expect(notifier.state.medications, isEmpty);
    });
  });
}


