// Widget test: Loading Widgets
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/app/widgets/loading_widgets.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';

void main() {
  group('LoadingWidgets Tests', () {
    setUp(() {
      setupTestEnvironment();
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should display circular progress indicator', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: LoadingWidgets.circularProgress(),
        ),
      );
      await tester.pump(); // Don't settle - CircularProgressIndicator animates continuously

      // Assert: Loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: LoadingWidgets.loadingButton(
            text: 'Submit',
            onPressed: () {},
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Button is displayed
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('should show loading state in button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: LoadingWidgets.loadingButton(
            text: 'Submit',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      await tester.pump(); // Don't settle - loading indicator animates continuously

      // Assert: Button shows loading (implementation dependent)
      // loadingButton returns an ElevatedButton, so find by that type
      expect(find.byType(ElevatedButton), findsOneWidget);
      // Also check for the loading indicator inside the button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

