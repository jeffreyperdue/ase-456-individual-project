// Widget test: Retry Widget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/app/widgets/retry_widget.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';

void main() {
  group('RetryWidget Tests', () {
    setUp(() {
      setupTestEnvironment();
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should display error message', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: RetryWidget(
            message: 'Something went wrong',
            onRetry: () {}, // Dummy callback
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Error message is displayed
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should display retry button when callback provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      var retried = false;

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: RetryWidget(
            message: 'Error occurred',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Retry button is present
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should call retry callback when button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var retried = false;

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: RetryWidget(
            message: 'Error occurred',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert: Callback was called
      expect(retried, isTrue);
    });
  });
}

