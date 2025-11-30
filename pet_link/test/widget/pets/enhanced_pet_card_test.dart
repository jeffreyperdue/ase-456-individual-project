// Widget test: Enhanced Pet Card
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pets/presentation/widgets/enhanced_pet_card.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/care_plans/application/pet_with_plan_provider.dart';
import 'package:petfolio/features/care_plans/application/care_task_provider.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';

void main() {
  group('EnhancedPetCard Widget Tests', () {
    setUp(() {
      setupTestEnvironment();
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render pet card with pet information', (
      WidgetTester tester,
    ) async {
      // Arrange: Pet
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(
        name: 'Buddy',
        species: 'Dog',
        ownerId: testUser.id,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: EnhancedPetCard(pet: testPet),
          overrides: [
            // Mock petWithPlanProvider to return a simple value
            petWithPlanProvider.overrideWith((ref, petId) {
              return AsyncValue.data(PetWithPlan.fromData(
                testPet,
                null, // No care plan
                const CareTaskStats(
                  total: 0,
                  overdue: 0,
                  dueSoon: 0,
                  today: 0,
                ),
              ));
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Pet information is displayed
      expect(find.text('Buddy'), findsOneWidget);
      expect(find.text('Dog'), findsOneWidget);
    });

    testWidgets('should display pet information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(
        name: 'Max',
        species: 'Cat',
        ownerId: testUser.id,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: EnhancedPetCard(pet: testPet),
          overrides: [
            // Mock petWithPlanProvider to return a simple value
            petWithPlanProvider.overrideWith((ref, petId) {
              return AsyncValue.data(PetWithPlan.fromData(
                testPet,
                null, // No care plan
                const CareTaskStats(
                  total: 0,
                  overdue: 0,
                  dueSoon: 0,
                  today: 0,
                ),
              ));
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Pet information is displayed
      expect(find.text('Max'), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
    });
  });
}

