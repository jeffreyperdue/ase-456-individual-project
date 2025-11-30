// Widget test: QR Code Widget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/sharing/presentation/widgets/qr_code_widget.dart';
import 'package:petfolio/features/sharing/domain/access_token.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';

void main() {
  group('QRCodeWidget Tests', () {
    setUp(() {
      setupTestEnvironment();
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render QR code with token', (
      WidgetTester tester,
    ) async {
      // Arrange: Access token
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: QRCodeWidget(token: testToken),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Widget renders
      expect(find.byType(QRCodeWidget), findsOneWidget);
    });

    testWidgets('should display title and subtitle when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: QRCodeWidget(
            token: testToken,
            title: 'Scan to Access',
            subtitle: 'Pet Profile',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Title and subtitle displayed
      expect(find.text('Scan to Access'), findsOneWidget);
      expect(find.text('Pet Profile'), findsOneWidget);
    });
  });
}

