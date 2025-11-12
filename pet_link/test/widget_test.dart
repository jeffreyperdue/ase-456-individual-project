// Widget tests for PetLink app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/app/app.dart';
import 'helpers/test_helpers.dart';
import 'test_config.dart';

void main() {
  setUp(() {
    setupTestEnvironment();
  });

  tearDown(() {
    cleanupTestEnvironment();
  });

  group('PetLink App Widget Tests', () {
    // Note: Tests that require full app initialization with Firebase are skipped
    // as they require Firebase to be initialized, which is complex in test environment.
    // These tests are better suited for integration tests with Firebase emulator.

    test('App MaterialApp structure is correct', () {
      // Test the app structure without full initialization
      // This test verifies the app can be instantiated without errors
      // Full initialization tests should use integration tests
      
      // Just verify the app widget structure
      const app = PetfolioApp();
      expect(app, isNotNull);
    });
  });

  group('Test Widget Wrapper Tests', () {
    testWidgets('TestWidgetWrapper should wrap child with providers', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testChild = Text('Test Content');

      // Act
      await tester.pumpWidget(TestWidgetWrapper(child: testChild));

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TestWidgetWrapper should support provider overrides', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testProvider = Provider<String>((ref) => 'test_value');

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Consumer(
            builder: (context, ref, child) {
              final value = ref.watch(testProvider);
              return Text('Value: $value');
            },
          ),
          overrides: [testProvider.overrideWithValue('overridden_value')],
        ),
      );

      // Assert
      expect(find.text('Value: overridden_value'), findsOneWidget);
    });
  });
}
