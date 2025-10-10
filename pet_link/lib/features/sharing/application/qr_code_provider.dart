import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pets/domain/pet.dart';
import '../domain/access_token.dart';
import '../application/create_access_token_use_case.dart';
import '../application/qr_code_service.dart';
import '../data/access_token_repository_impl.dart';

/// Provider for the QR code service.
final qrCodeServiceProvider = Provider<QRCodeService>((ref) {
  return QRCodeService();
});

/// Provider for the access token repository.
final accessTokenRepositoryProvider = Provider<AccessTokenRepositoryImpl>((
  ref,
) {
  return AccessTokenRepositoryImpl();
});

/// Provider for the create access token use case.
final createAccessTokenUseCaseProvider = Provider<CreateAccessTokenUseCase>((
  ref,
) {
  final repository = ref.watch(accessTokenRepositoryProvider);
  return CreateAccessTokenUseCase(repository);
});

/// Provider for managing QR code generation for a specific pet.
final qrCodeProvider = FutureProvider.family<AccessToken?, Pet>((
  ref,
  pet,
) async {
  final createTokenUseCase = ref.watch(createAccessTokenUseCaseProvider);

  try {
    // Create a viewer token for QR code sharing
    final token = await createTokenUseCase.execute(
      petId: pet.id,
      grantedBy: pet.ownerId,
      role: AccessRole.viewer,
      expiresAt: DateTime.now().add(const Duration(days: 7)), // Default 7 days
      notes: 'QR Code sharing access',
    );

    return token;
  } catch (e) {
    // Return null if token creation fails
    return null;
  }
});

/// Provider for managing active access tokens for a pet.
final petAccessTokensProvider =
    FutureProvider.family<List<AccessToken>, String>((ref, petId) async {
      final repository = ref.watch(accessTokenRepositoryProvider);

      try {
        return await repository.getAccessTokensForPet(petId);
      } catch (e) {
        return [];
      }
    });

/// Provider for managing access tokens created by a user.
final userAccessTokensProvider =
    FutureProvider.family<List<AccessToken>, String>((ref, userId) async {
      final repository = ref.watch(accessTokenRepositoryProvider);

      try {
        return await repository.getAccessTokensByUser(userId);
      } catch (e) {
        return [];
      }
    });

/// State notifier for managing QR code generation state.
class QRCodeNotifier extends StateNotifier<AsyncValue<AccessToken?>> {
  final CreateAccessTokenUseCase _createTokenUseCase;
  final QRCodeService _qrCodeService;

  QRCodeNotifier(this._createTokenUseCase, this._qrCodeService)
    : super(const AsyncValue.data(null));

  /// Generate a QR code token for a pet.
  Future<void> generateQRToken({
    required String petId,
    required String grantedBy,
    AccessRole role = AccessRole.viewer,
    Duration? duration,
    String? notes,
    String? grantedTo,
    String? contactInfo,
  }) async {
    state = const AsyncValue.loading();

    try {
      final expiresAt = DateTime.now().add(duration ?? const Duration(days: 7));

      final token = await _createTokenUseCase.execute(
        petId: petId,
        grantedBy: grantedBy,
        role: role,
        expiresAt: expiresAt,
        notes: notes,
        grantedTo: grantedTo,
        contactInfo: contactInfo,
      );

      state = AsyncValue.data(token);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Clear the current token.
  void clearToken() {
    state = const AsyncValue.data(null);
  }

  /// Share the current token.
  Future<void> shareToken({String? subject, String? text}) async {
    final token = state.value;
    if (token == null) return;

    try {
      await _qrCodeService.shareURL(token: token, subject: subject, text: text);
    } catch (e) {
      // Handle sharing error
      rethrow;
    }
  }
}

/// Provider for the QR code notifier.
final qrCodeNotifierProvider =
    StateNotifierProvider<QRCodeNotifier, AsyncValue<AccessToken?>>((ref) {
      final createTokenUseCase = ref.watch(createAccessTokenUseCaseProvider);
      final qrCodeService = ref.watch(qrCodeServiceProvider);
      return QRCodeNotifier(createTokenUseCase, qrCodeService);
    });
