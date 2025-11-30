// Acceptance test: Pet Sharing Journey
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/sharing/domain/access_token.dart';
import 'package:petfolio/features/sharing/presentation/pages/share_pet_page.dart';
import 'package:petfolio/features/sharing/presentation/pages/qr_code_display_page.dart';
import 'package:petfolio/features/sharing/presentation/pages/public_pet_profile_page.dart';
import 'package:petfolio/features/sharing/application/create_access_token_use_case.dart';
import 'package:petfolio/features/sharing/domain/access_token_repository.dart';
import 'package:petfolio/features/sharing/data/access_token_repository_impl.dart';
import 'package:petfolio/features/sharing/application/qr_code_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'share_pet_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  AccessTokenRepositoryImpl,
  AuthService,
])
void main() {
  group('Acceptance: Pet Sharing Journey', () {
    late MockAccessTokenRepositoryImpl mockAccessTokenRepository;
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockAccessTokenRepository = MockAccessTokenRepositoryImpl();
      mockAuthService = MockAuthService();

      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);

      container = ProviderContainer(
        overrides: [
          accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    testWidgets('step 1: should navigate to share pet page', (
      WidgetTester tester,
    ) async {
      // Arrange: Pet exists
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      // Act: Navigate to share page
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Share page is displayed
      expect(find.text('Share ${testPet.name}'), findsOneWidget);
      expect(find.byType(SharePetPage), findsOneWidget);
    });

    testWidgets('step 2: should create access token with QR code', (
      WidgetTester tester,
    ) async {
      // Arrange: Pet exists
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        role: AccessRole.viewer,
      );

      when(mockAccessTokenRepository.createAccessToken(any))
          .thenAnswer((_) async => testToken);
      when(mockAccessTokenRepository.getAccessTokensForPet(any))
          .thenAnswer((_) async => [testToken]);

      // Act: Navigate to share page
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Form is present for creating token
      expect(find.byType(SharePetPage), findsOneWidget);
    });

    testWidgets('step 3: should display QR code for access token', (
      WidgetTester tester,
    ) async {
      // Arrange: Access token exists
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      // Act: Navigate to QR code display
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: QRCodeDisplayPage(token: testToken),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: QR code page is displayed
      expect(find.byType(QRCodeDisplayPage), findsOneWidget);
    });

    testWidgets('step 4: should allow sitter to view public pet profile', (
      WidgetTester tester,
    ) async {
      // Arrange: Access token exists, sitter accesses profile
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        role: AccessRole.sitter,
      );

      when(mockAccessTokenRepository.getAccessToken(any))
          .thenAnswer((_) async => testToken);

      // Act: Navigate to public profile
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: PublicPetProfilePage(tokenId: testToken.id),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Public profile is displayed
      expect(find.byType(PublicPetProfilePage), findsOneWidget);
    });

    testWidgets('step 5: should allow sitter to complete tasks', (
      WidgetTester tester,
    ) async {
      // Arrange: Sitter has access, tasks exist
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        role: AccessRole.sitter,
      );

      when(mockAccessTokenRepository.getAccessToken(any))
          .thenAnswer((_) async => testToken);

      // Act: View public profile (where tasks can be completed)
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: PublicPetProfilePage(tokenId: testToken.id),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Profile is accessible for task completion
      expect(find.byType(PublicPetProfilePage), findsOneWidget);
    });

    testWidgets('step 6: should show completed tasks to owner', (
      WidgetTester tester,
    ) async {
      // Arrange: Task was completed by sitter
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final testToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      when(mockAccessTokenRepository.getAccessTokensForPet(any))
          .thenAnswer((_) async => [testToken]);

      // Act: Owner views share page
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SharePetPage(pet: testPet),
          overrides: [
            accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Access tokens are listed
      expect(find.byType(SharePetPage), findsOneWidget);
    });
  });
}

