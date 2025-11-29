import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/application/save_care_plan_use_case.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/care_plan_repository.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';

class _FakeCarePlanRepository implements CarePlanRepository {
  final Map<String, CarePlan> _plans = {};
  final Set<String> petsWithPlans = {};

  @override
  Future<void> createCarePlan(CarePlan carePlan) async {
    _plans[carePlan.id] = carePlan;
    petsWithPlans.add(carePlan.petId);
  }

  @override
  Future<void> deleteCarePlan(String carePlanId) async {
    final existing = _plans.remove(carePlanId);
    if (existing != null) {
      petsWithPlans.remove(existing.petId);
    }
  }

  @override
  Future<CarePlan?> getCarePlan(String carePlanId) async {
    return _plans[carePlanId];
  }

  @override
  Future<bool> carePlanExistsForPet(String petId) async {
    return petsWithPlans.contains(petId);
  }

  @override
  Future<void> updateCarePlan(String carePlanId, Map<String, dynamic> data) async {
    final existing = _plans[carePlanId];
    if (existing != null) {
      _plans[carePlanId] = existing.copyWith(
        dietText: data['dietText'] as String? ?? existing.dietText,
        feedingSchedules: (data['feedingSchedules'] as List?)
                ?.map((e) => FeedingSchedule.fromJson(e as Map<String, dynamic>))
                .toList() ??
            existing.feedingSchedules,
        medications: (data['medications'] as List?)
                ?.map((e) => Medication.fromJson(e as Map<String, dynamic>))
                .toList() ??
            existing.medications,
        timezone: data['timezone'] as String? ?? existing.timezone,
        updatedAt: data['updatedAt'] as DateTime? ?? existing.updatedAt,
      );
    }
  }

  // Unused for these tests
  @override
  Stream<CarePlan?> watchCarePlanForPet(String petId) {
    throw UnimplementedError();
  }
}

void main() {
  group('SaveCarePlanUseCase', () {
    late _FakeCarePlanRepository repository;
    late SaveCarePlanUseCase useCase;

    setUp(() {
      repository = _FakeCarePlanRepository();
      useCase = SaveCarePlanUseCase(repository);
    });

    CarePlan _validPlan({String id = 'plan1', String petId = 'pet1'}) {
      return CarePlan(
        id: id,
        petId: petId,
        ownerId: 'owner1',
        dietText: 'Diet info',
        feedingSchedules: const [
          FeedingSchedule(
            id: 'feed1',
            label: 'Breakfast',
            times: ['07:00'],
          ),
        ],
        medications: const [
          Medication(
            id: 'med1',
            name: 'Med',
            dosage: '1 tablet',
            times: ['09:00'],
          ),
        ],
      );
    }

    test('throws CarePlanValidationException when validation fails', () async {
      final invalidPlan = CarePlan(
        id: 'invalid',
        petId: 'pet1',
        ownerId: 'owner1',
        dietText: '',
        feedingSchedules: const [],
        medications: const [],
      );

      expect(
        () => useCase.execute(invalidPlan),
        throwsA(isA<CarePlanValidationException>()),
      );
    });

    test('creates new care plan when it does not exist', () async {
      final plan = _validPlan();

      final saved = await useCase.execute(plan);

      final fromRepo = await repository.getCarePlan(plan.id);
      expect(fromRepo, isNotNull);
      expect(saved.id, plan.id);
      expect(saved.dietText, plan.dietText);
    });

    test('throws DuplicateCarePlanException when plan already exists for pet', () async {
      final firstPlan = _validPlan(id: 'plan1', petId: 'pet1');
      await repository.createCarePlan(firstPlan);

      final newPlan = _validPlan(id: 'plan2', petId: 'pet1');

      expect(
        () => useCase.execute(newPlan),
        throwsA(isA<DuplicateCarePlanException>()),
      );
    });

    test('updates existing care plan when id already exists', () async {
      final original = _validPlan();
      await repository.createCarePlan(original);

      final updated = original.copyWith(
        dietText: 'Updated diet',
        feedingSchedules: const [
          FeedingSchedule(
            id: 'feed1',
            label: 'Dinner',
            times: ['18:00'],
          ),
        ],
      );

      final result = await useCase.execute(updated);

      final fromRepo = await repository.getCarePlan(original.id);
      expect(fromRepo, isNotNull);
      expect(fromRepo!.dietText, 'Updated diet');
      expect(fromRepo.feedingSchedules.first.label, 'Dinner');
      expect(result.dietText, 'Updated diet');
    });
  });
}


