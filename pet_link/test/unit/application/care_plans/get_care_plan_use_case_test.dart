import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/application/get_care_plan_use_case.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/care_plan_repository.dart';

class _FakeCarePlanRepository implements CarePlanRepository {
  final Map<String, CarePlan> plansById = {};
  final Set<String> petsWithPlans = {};

  @override
  Future<CarePlan?> getCarePlan(String carePlanId) async {
    return plansById[carePlanId];
  }

  @override
  Future<bool> carePlanExistsForPet(String petId) async {
    return petsWithPlans.contains(petId);
  }

  @override
  Future<void> createCarePlan(CarePlan carePlan) async {
    plansById[carePlan.id] = carePlan;
    petsWithPlans.add(carePlan.petId);
  }

  // Unused for these tests
  @override
  Stream<CarePlan?> watchCarePlanForPet(String petId) =>
      const Stream.empty();

  @override
  Future<void> deleteCarePlan(String carePlanId) async {}

  @override
  Future<void> updateCarePlan(
    String carePlanId,
    Map<String, dynamic> updates,
  ) async {}
}

void main() {
  group('GetCarePlanUseCase', () {
    late _FakeCarePlanRepository repository;
    late GetCarePlanUseCase useCase;

    setUp(() {
      repository = _FakeCarePlanRepository();
      useCase = GetCarePlanUseCase(repository);
    });

    CarePlan _plan({required String id, required String petId}) => CarePlan(
          id: id,
          petId: petId,
          ownerId: 'owner1',
          dietText: 'Diet',
          feedingSchedules: const [],
          medications: const [],
        );

    test('getCarePlan returns plan by id when it exists', () async {
      final plan = _plan(id: 'plan1', petId: 'pet1');
      await repository.createCarePlan(plan);

      final result = await useCase.getCarePlan('plan1');

      expect(result, equals(plan));
    });

    test('getCarePlan returns null when plan does not exist', () async {
      final result = await useCase.getCarePlan('missing');

      expect(result, isNull);
    });

    test('getCarePlanForPet returns null when pet has no plan', () async {
      final result = await useCase.getCarePlanForPet('pet1');

      expect(result, isNull);
    });

    test('getCarePlanForPet uses naming convention when plan exists', () async {
      final plan = _plan(id: 'pet1_care_plan', petId: 'pet1');
      await repository.createCarePlan(plan);

      final result = await useCase.getCarePlanForPet('pet1');

      expect(result, equals(plan));
    });
  });
}


