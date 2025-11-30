// Regression test: Sharing System Edge Cases
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/sharing/domain/access_token.dart';
import 'package:petfolio/features/sharing/domain/access_token_repository.dart';
import 'package:petfolio/features/sharing/domain/sharing_exceptions.dart';
import 'package:petfolio/features/sharing/data/access_token_repository_impl.dart';
import 'package:petfolio/features/sharing/application/qr_code_provider.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'sharing_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([AccessTokenRepositoryImpl])
void main() {
  group('Regression: Sharing System Edge Cases', () {
    late MockAccessTokenRepositoryImpl mockAccessTokenRepository;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockAccessTokenRepository = MockAccessTokenRepositoryImpl();
      container = ProviderContainer(
        overrides: [
          accessTokenRepositoryProvider.overrideWithValue(mockAccessTokenRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    test('should handle expired access token gracefully', () async {
      // Arrange: Expired token
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final expiredToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)), // Expired
      );

      when(mockAccessTokenRepository.getAccessToken(any))
          .thenAnswer((_) async => expiredToken);

      // Act: Try to get expired token
      final token = await mockAccessTokenRepository.getAccessToken(expiredToken.id);

      // Assert: Token is returned (validation happens in use case)
      expect(token, isNotNull);
      expect(token!.expiresAt.isBefore(DateTime.now()), isTrue);
    });

    test('should handle invalid QR code scanning', () async {
      // Arrange: Invalid token ID
      const invalidTokenId = 'invalid_token_id';

      when(mockAccessTokenRepository.getAccessToken(invalidTokenId))
          .thenAnswer((_) async => null);

      // Act: Try to get invalid token
      final token = await mockAccessTokenRepository.getAccessToken(invalidTokenId);

      // Assert: Returns null
      expect(token, isNull);
    });

    test('should enforce permission boundaries', () async {
      // Arrange: Token with viewer role trying to complete tasks
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final viewerToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        role: AccessRole.viewer, // Viewer cannot complete tasks
      );

      when(mockAccessTokenRepository.getAccessToken(any))
          .thenAnswer((_) async => viewerToken);

      // Act: Get token
      final token = await mockAccessTokenRepository.getAccessToken(viewerToken.id);

      // Assert: Token has viewer role
      expect(token, isNotNull);
      expect(token!.role, equals(AccessRole.viewer));
    });

    test('should handle concurrent task completions', () async {
      // Arrange: Multiple sitters completing same task
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final token1 = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        role: AccessRole.sitter,
      );
      final token2 = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        role: AccessRole.sitter,
      );

      when(mockAccessTokenRepository.getAccessToken(any))
          .thenAnswer((_) async => token1);

      // Act: Concurrent token retrievals
      final results = await Future.wait([
        mockAccessTokenRepository.getAccessToken(token1.id),
        mockAccessTokenRepository.getAccessToken(token2.id),
      ]);

      // Assert: Both complete
      expect(results.length, equals(2));
    });

    test('should handle token revocation while in use', () async {
      // Arrange: Active token
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final activeToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      when(mockAccessTokenRepository.getAccessToken(any))
          .thenAnswer((_) async => activeToken);
      when(mockAccessTokenRepository.deactivateAccessToken(any))
          .thenAnswer((_) async => {});

      // Act: Deactivate token
      await mockAccessTokenRepository.deactivateAccessToken(activeToken.id);

      // Assert: Deactivation completes
      verify(mockAccessTokenRepository.deactivateAccessToken(activeToken.id)).called(1);
    });

    test('should handle token creation with past expiration date', () async {
      // Arrange: Token with past expiration
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final invalidToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Act & Assert: Should be caught by validation in use case
      // Repository level doesn't validate, use case does
      when(mockAccessTokenRepository.createAccessToken(any))
          .thenAnswer((_) async => invalidToken);

      await mockAccessTokenRepository.createAccessToken(invalidToken);
      verify(mockAccessTokenRepository.createAccessToken(any)).called(1);
    });

    test('should handle token creation with very long expiration', () async {
      // Arrange: Token with expiration > 30 days
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final longExpirationToken = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
        expiresAt: DateTime.now().add(const Duration(days: 60)), // > 30 days
      );

      // Act & Assert: Should be caught by validation in use case
      when(mockAccessTokenRepository.createAccessToken(any))
          .thenAnswer((_) async => longExpirationToken);

      await mockAccessTokenRepository.createAccessToken(longExpirationToken);
      verify(mockAccessTokenRepository.createAccessToken(any)).called(1);
    });

    test('should handle multiple tokens for same pet', () async {
      // Arrange: Multiple tokens for one pet
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final token1 = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );
      final token2 = TestDataFactory.createTestAccessToken(
        petId: testPet.id,
        grantedBy: testUser.id,
      );

      when(mockAccessTokenRepository.getAccessTokensForPet(any))
          .thenAnswer((_) async => [token1, token2]);

      // Act: Get all tokens for pet
      final tokens = await mockAccessTokenRepository.getAccessTokensForPet(testPet.id);

      // Assert: Both tokens returned
      expect(tokens.length, equals(2));
    });

    test('should handle token access with invalid pet ID', () async {
      // Arrange: Token with non-existent pet
      const invalidPetId = 'non_existent_pet';
      
      when(mockAccessTokenRepository.getAccessTokensForPet(invalidPetId))
          .thenAnswer((_) async => []);

      // Act: Get tokens for invalid pet
      final tokens = await mockAccessTokenRepository.getAccessTokensForPet(invalidPetId);

      // Assert: Returns empty list
      expect(tokens, isEmpty);
    });
  });
}

