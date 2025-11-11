import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/lost_found/data/lost_report_repository.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';
import 'package:petfolio/features/lost_found/application/poster_generator_service.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;

/// Provider for LostReportRepository
final lostReportRepositoryProvider = Provider<LostReportRepository>((ref) {
  return LostReportRepository();
});

/// Provider for PosterGeneratorService
final posterGeneratorServiceProvider =
    Provider<PosterGeneratorService>((ref) {
  return PosterGeneratorService();
});

/// Provider for lost report for a specific pet
final lostReportProvider = StreamProvider.family<LostReport?, String>(
  (ref, petId) {
    final repository = ref.watch(lostReportRepositoryProvider);
    return repository.watchLostReportForPet(petId);
  },
);

/// Notifier for managing lost pet operations
class LostFoundNotifier extends StateNotifier<AsyncValue<void>> {
  LostFoundNotifier(
    this._lostReportRepository,
    this._petsRepository,
  ) : super(const AsyncValue.data(null));

  final LostReportRepository _lostReportRepository;
  final PetsRepository _petsRepository;

  /// Mark a pet as lost
  Future<void> markPetAsLost({
    required Pet pet,
    required app_user.User owner,
    String? lastSeenLocation,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Update pet's isLost status
      await _petsRepository.updatePet(pet.id, {'isLost': true});

      // Create lost report
      final lostDate = DateTime.now();
      final reportId = DateTime.now().millisecondsSinceEpoch.toString();
      final lostReport = LostReport(
        id: reportId,
        petId: pet.id,
        ownerId: owner.id,
        createdAt: lostDate,
        lastSeenLocation: lastSeenLocation,
        notes: notes,
      );

      await _lostReportRepository.createLostReport(lostReport);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Mark a pet as found
  Future<void> markPetAsFound({
    required Pet pet,
    required LostReport? lostReport,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Update pet's isLost status
      await _petsRepository.updatePet(pet.id, {'isLost': false});

      // Delete lost report if it exists
      if (lostReport != null) {
        await _lostReportRepository.deleteLostReport(lostReport.id);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

}

/// Provider for LostFoundNotifier
final lostFoundNotifierProvider =
    StateNotifierProvider<LostFoundNotifier, AsyncValue<void>>((ref) {
  return LostFoundNotifier(
    ref.watch(lostReportRepositoryProvider),
    ref.watch(petsRepositoryProvider),
  );
});

