import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/access_token.dart';
import '../domain/access_token_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Firestore implementation of the AccessTokenRepository.
class AccessTokenRepositoryImpl implements AccessTokenRepository {
  final FirebaseFirestore _firestore;

  AccessTokenRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'access_tokens';

  @override
  Future<AccessToken> createAccessToken(AccessToken token) async {
    try {
      final docRef = _firestore.collection(_collection).doc(token.id);
      await docRef.set(token.toJson());
      return token;
    } catch (e) {
      throw AccessTokenException('Failed to create access token: $e');
    }
  }

  @override
  Future<AccessToken?> getAccessToken(String tokenId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(tokenId).get();
      if (!doc.exists) return null;
      return AccessToken.fromJson(doc.data()!);
    } catch (e) {
      throw AccessTokenException('Failed to get access token: $e');
    }
  }

  @override
  Future<List<AccessToken>> getAccessTokensForPet(String petId) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('petId', isEqualTo: petId)
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) => AccessToken.fromJson(doc.data())).toList();
    } catch (e) {
      throw AccessTokenException('Failed to get access tokens for pet: $e');
    }
  }

  @override
  Future<List<AccessToken>> getAccessTokensByUser(String userId) async {
    try {
      // Get tokens granted TO this user (for sitters)
      final grantedToQuery =
          await _firestore
              .collection(_collection)
              .where('grantedTo', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      // Get tokens granted BY this user (for owners)
      final grantedByQuery =
          await _firestore
              .collection(_collection)
              .where('grantedBy', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      final allTokens = <AccessToken>[];
      allTokens.addAll(
        grantedToQuery.docs.map((doc) => AccessToken.fromJson(doc.data())),
      );
      allTokens.addAll(
        grantedByQuery.docs.map((doc) => AccessToken.fromJson(doc.data())),
      );

      return allTokens;
    } catch (e) {
      throw AccessTokenException('Failed to get access tokens by user: $e');
    }
  }

  @override
  Future<void> updateAccessToken(AccessToken token) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(token.id)
          .update(token.toJson());
    } catch (e) {
      throw AccessTokenException('Failed to update access token: $e');
    }
  }

  @override
  Future<void> deleteAccessToken(String tokenId) async {
    try {
      await _firestore.collection(_collection).doc(tokenId).delete();
    } catch (e) {
      throw AccessTokenException('Failed to delete access token: $e');
    }
  }

  @override
  Future<void> deactivateAccessToken(String tokenId) async {
    try {
      await _firestore.collection(_collection).doc(tokenId).update({
        'isActive': false,
      });
    } catch (e) {
      throw AccessTokenException('Failed to deactivate access token: $e');
    }
  }

  @override
  Future<List<AccessToken>> getExpiredTokens() async {
    try {
      final now = DateTime.now().toIso8601String();
      final query =
          await _firestore
              .collection(_collection)
              .where('expiresAt', isLessThan: now)
              .where('isActive', isEqualTo: true)
              .get();

      return query.docs.map((doc) => AccessToken.fromJson(doc.data())).toList();
    } catch (e) {
      throw AccessTokenException('Failed to get expired tokens: $e');
    }
  }

  @override
  Future<void> deleteExpiredTokens() async {
    try {
      final expiredTokens = await getExpiredTokens();
      final batch = _firestore.batch();

      for (final token in expiredTokens) {
        batch.delete(_firestore.collection(_collection).doc(token.id));
      }

      if (expiredTokens.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      throw AccessTokenException('Failed to delete expired tokens: $e');
    }
  }

  @override
  Future<bool> isTokenValid(String tokenId) async {
    try {
      final token = await getAccessToken(tokenId);
      return token?.isValid ?? false;
    } catch (e) {
      throw AccessTokenException('Failed to validate token: $e');
    }
  }

  @override
  Future<AccessToken?> getTokenByPetAndUser(
    String petId,
    String userId,
    AccessRole role,
  ) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('petId', isEqualTo: petId)
              .where('grantedTo', isEqualTo: userId)
              .where('role', isEqualTo: role.name)
              .where('isActive', isEqualTo: true)
              .get();

      if (query.docs.isEmpty) return null;

      final token = AccessToken.fromJson(query.docs.first.data());
      return token.isValid ? token : null;
    } catch (e) {
      throw AccessTokenException('Failed to get token by pet and user: $e');
    }
  }
}
