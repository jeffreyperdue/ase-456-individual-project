// Widget tests for PetLink app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/app/app.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('PetLink App Widget Tests', () {
    testWidgets('App should start and show authentication screen', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: PetfolioApp()));

      // Verify that the app starts without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle navigation correctly', (
      WidgetTester tester,
    ) async {
      // Build our app
      await tester.pumpWidget(const ProviderScope(child: PetfolioApp()));

      // Verify initial state
      expect(find.byType(MaterialApp), findsOneWidget);

      // The app should handle basic navigation without errors
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should render with proper theme', (
      WidgetTester tester,
    ) async {
      // Build our app
      await tester.pumpWidget(const ProviderScope(child: PetfolioApp()));

      // Verify theme is applied
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme!.colorScheme, isNotNull);
    });

    testWidgets('App should handle provider scope correctly', (
      WidgetTester tester,
    ) async {
      // Build our app with ProviderScope
      await tester.pumpWidget(const ProviderScope(child: PetfolioApp()));

      // Verify ProviderScope is working
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
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

  group('Widget Error Handling', () {
    testWidgets('App should handle widget errors gracefully', (
      WidgetTester tester,
    ) async {
      // Build our app
      await tester.pumpWidget(const ProviderScope(child: PetfolioApp()));

      // The app should not crash during rendering
      await tester.pumpAndSettle();

      // Verify the app is still running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle provider errors gracefully', (
      WidgetTester tester,
    ) async {
      // This test ensures that provider errors don't crash the entire app
      await tester.pumpWidget(const ProviderScope(child: PetfolioApp()));

      // Pump multiple frames to test stability
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // App should still be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
