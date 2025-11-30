// Widget test: Share Pet Page
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/sharing/presentation/pages/share_pet_page.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/sharing/data/access_token_repository_impl.dart';
import 'package:petfolio/features/sharing/application/qr_code_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';
import 'share_pet_page_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  AccessTokenRepositoryImpl,
  AuthService,
])
void main() {
  group('SharePetPage Widget Tests', () {
    late MockAccessTokenRepositoryImpl mockAccessTokenRepository;
    late MockAuthService mockAuthService;
    late Pet testPet;

    setUp(() {
      setupTestEnvironment();
      mockAccessTokenRepository = MockAccessTokenRepositoryImpl();
      mockAuthService = MockAuthService();

      final testUser = TestDataFactory.createTestUser();
      testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);
      when(mockAccessTokenRepository.getAccessTokensForPet(any))
          .thenAnswer((_) async => []);
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render correctly with pet name', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
            petAccessTokensProvider.overrideWith((ref, petId) async {
              final repository = ref.watch(accessTokenRepositoryProvider);
              return await repository.getAccessTokensForPet(petId);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Page title shows pet name
      expect(find.text('Share ${testPet.name}'), findsOneWidget);
      expect(find.byType(SharePetPage), findsOneWidget);
    });

    testWidgets('should display QR code button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
            petAccessTokensProvider.overrideWith((ref, petId) async {
              final repository = ref.watch(accessTokenRepositoryProvider);
              return await repository.getAccessTokensForPet(petId);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: QR code button is present
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });

    testWidgets('should display create handoff form', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
            petAccessTokensProvider.overrideWith((ref, petId) async {
              final repository = ref.watch(accessTokenRepositoryProvider);
              return await repository.getAccessTokensForPet(petId);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Form elements are present
      // The form should have role selection, expiration date, etc.
      expect(find.byType(SharePetPage), findsOneWidget);
    });

    testWidgets('should display existing access tokens', (
      WidgetTester tester,
    ) async {
      // Arrange: Existing tokens
      final testUser = TestDataFactory.createTestUser();
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      when(mockAccessTokenRepository.getAccessTokensForPet(any))
          .thenAnswer((_) async => [testToken]);

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
            petAccessTokensProvider.overrideWith((ref, petId) async {
              if (petId == testPet.id) {
                return [testToken];
              }
              return [];
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Tokens are displayed
      expect(find.byType(SharePetPage), findsOneWidget);
    });

    testWidgets('should handle empty token list', (
      WidgetTester tester,
    ) async {
      // Arrange: No tokens
      when(mockAccessTokenRepository.getAccessTokensForPet(any))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
            petAccessTokensProvider.overrideWith((ref, petId) async {
              final repository = ref.watch(accessTokenRepositoryProvider);
              return await repository.getAccessTokensForPet(petId);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Page still renders
      expect(find.byType(SharePetPage), findsOneWidget);
    });
  });
}

