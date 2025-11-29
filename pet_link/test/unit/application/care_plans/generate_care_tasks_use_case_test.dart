import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/application/generate_care_tasks_use_case.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/care_task.dart';
import 'package:petfolio/features/care_plans/services/care_task_generator.dart';

class _FakeCareTaskGenerator implements CareTaskGenerator {
  List<CareTask> generatedTasks = [];
  List<CareTask> overdueTasks = [];
  List<CareTask> dueSoonTasks = [];
  List<CareTask> todayTasks = [];

  @override
  List<CareTask> generateUpcomingTasks(CarePlan carePlan) {
    return generatedTasks;
  }

  @override
  List<CareTask> getOverdueTasks(List<CareTask> tasks) {
    return overdueTasks;
  }

  @override
  List<CareTask> getTasksDueSoon(List<CareTask> tasks) {
    return dueSoonTasks;
  }

  @override
  List<CareTask> getTodayTasks(List<CareTask> tasks) {
    return todayTasks;
  }
}

void main() {
  group('GenerateCareTasksUseCase', () {
    late _FakeCareTaskGenerator fakeGenerator;
    late GenerateCareTasksUseCase useCase;
    late CarePlan carePlan;

    setUp(() {
      fakeGenerator = _FakeCareTaskGenerator();
      useCase = GenerateCareTasksUseCase(fakeGenerator);
      carePlan = CarePlan(
        id: 'plan1',
        petId: 'pet1',
        ownerId: 'owner1',
        dietText: 'Test diet',
        feedingSchedules: const [],
        medications: const [],
      );
    });

    CareTask _task(String id) => CareTask(
          id: id,
          petId: 'pet1',
          carePlanId: 'plan1',
          type: CareTaskType.feeding,
          title: 'Task $id',
          description: 'Desc',
          scheduledTime: DateTime(2024, 1, 15, 12, 0),
        );

    test('execute delegates to CareTaskGenerator.generateUpcomingTasks', () {
      fakeGenerator.generatedTasks = [_task('1'), _task('2')];

      final tasks = useCase.execute(carePlan);

      expect(tasks, equals(fakeGenerator.generatedTasks));
    });

    test('getOverdueTasks delegates to CareTaskGenerator.getOverdueTasks', () {
      final inputTasks = [_task('1'), _task('2')];
      fakeGenerator.overdueTasks = [_task('1')];

      final result = useCase.getOverdueTasks(inputTasks);

      expect(result, equals(fakeGenerator.overdueTasks));
    });

    test('getTasksDueSoon delegates to CareTaskGenerator.getTasksDueSoon', () {
      final inputTasks = [_task('1'), _task('2')];
      fakeGenerator.dueSoonTasks = [_task('2')];

      final result = useCase.getTasksDueSoon(inputTasks);

      expect(result, equals(fakeGenerator.dueSoonTasks));
    });

    test('getTodayTasks delegates to CareTaskGenerator.getTodayTasks', () {
      final inputTasks = [_task('1'), _task('2')];
      fakeGenerator.todayTasks = [_task('1'), _task('2')];

      final result = useCase.getTodayTasks(inputTasks);

      expect(result, equals(fakeGenerator.todayTasks));
    });
  });
}


