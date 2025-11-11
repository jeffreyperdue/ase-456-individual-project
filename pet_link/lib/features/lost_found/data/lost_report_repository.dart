import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';

/// LostReportRepository centralizes all Firestore operations for LostReports.
/// Keeping data access in one place makes the UI simpler and easier to test.
class LostReportRepository {
  LostReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Create a new lost report in Firestore.
  Future<void> createLostReport(LostReport report) async {
    await _firestore.collection('lost_reports').doc(report.id).set({
      'petId': report.petId,
      'ownerId': report.ownerId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenLocation': report.lastSeenLocation,
      'notes': report.notes,
      'posterUrl': report.posterUrl,
    });
  }

  /// Get the active lost report for a pet (if any).
  /// Returns null if no active lost report exists.
  Future<LostReport?> getLostReportByPetId(String petId) async {
    try {
      final querySnapshot = await _firestore
          .collection('lost_reports')
          .where('petId', isEqualTo: petId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return LostReport.fromFirestore(doc.id, doc.data());
    } catch (e) {
      return null;
    }
  }

  /// Stream of lost report for a pet (real-time updates).
  Stream<LostReport?> watchLostReportForPet(String petId) {
    return _firestore
        .collection('lost_reports')
        .where('petId', isEqualTo: petId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return LostReport.fromFirestore(doc.id, doc.data());
    });
  }

  /// Update a lost report.
  Future<void> updateLostReport(String reportId, Map<String, dynamic> updates) async {
    await _firestore.collection('lost_reports').doc(reportId).update(updates);
  }

  /// Delete a lost report (when pet is found).
  Future<void> deleteLostReport(String reportId) async {
    await _firestore.collection('lost_reports').doc(reportId).delete();
  }

  /// Get all lost reports for an owner.
  Stream<List<LostReport>> watchLostReportsForOwner(String ownerId) {
    return _firestore
        .collection('lost_reports')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LostReport.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }
}

