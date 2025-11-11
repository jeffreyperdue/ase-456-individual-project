import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_completion.dart';
import '../domain/task_completion_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Firestore implementation of the TaskCompletionRepository.
class TaskCompletionRepositoryImpl implements TaskCompletionRepository {
  final FirebaseFirestore _firestore;

  TaskCompletionRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'task_completions';

  @override
  Future<TaskCompletion> createTaskCompletion(TaskCompletion completion) async {
    try {
      final docRef = _firestore.collection(_collection).doc(completion.id);
      // Store completedAt as Timestamp for proper Firestore querying
      final data = completion.toJson();
      data['completedAt'] = Timestamp.fromDate(completion.completedAt);
      await docRef.set(data);
      return completion;
    } catch (e) {
      throw AccessTokenException('Failed to create task completion: $e');
    }
  }

  @override
  Future<TaskCompletion?> getTaskCompletion(String completionId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(completionId).get();
      if (!doc.exists) return null;
      return _documentToTaskCompletion(doc);
    } catch (e) {
      throw AccessTokenException('Failed to get task completion: $e');
    }
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsForPet(String petId) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('petId', isEqualTo: petId)
              .orderBy('completedAt', descending: true)
              .get();

      return query.docs
          .map((doc) => _documentToTaskCompletion(doc))
          .toList();
    } catch (e) {
      throw AccessTokenException('Failed to get task completions for pet: $e');
    }
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsByUser(String userId) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('completedBy', isEqualTo: userId)
              .orderBy('completedAt', descending: true)
              .get();

      return query.docs
          .map((doc) => _documentToTaskCompletion(doc))
          .toList();
    } catch (e) {
      throw AccessTokenException('Failed to get task completions by user: $e');
    }
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsForTask(
    String careTaskId,
  ) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('careTaskId', isEqualTo: careTaskId)
              .orderBy('completedAt', descending: true)
              .get();

      return query.docs
          .map((doc) => _documentToTaskCompletion(doc))
          .toList();
    } catch (e) {
      throw AccessTokenException('Failed to get task completions for task: $e');
    }
  }

  @override
  Future<void> updateTaskCompletion(TaskCompletion completion) async {
    try {
      final data = completion.toJson();
      data['completedAt'] = Timestamp.fromDate(completion.completedAt);
      await _firestore
          .collection(_collection)
          .doc(completion.id)
          .update(data);
    } catch (e) {
      throw AccessTokenException('Failed to update task completion: $e');
    }
  }

  @override
  Future<void> deleteTaskCompletion(String completionId) async {
    try {
      await _firestore.collection(_collection).doc(completionId).delete();
    } catch (e) {
      throw AccessTokenException('Failed to delete task completion: $e');
    }
  }

  @override
  Future<bool> isTaskCompletedByUser(String careTaskId, String userId) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('careTaskId', isEqualTo: careTaskId)
              .where('completedBy', isEqualTo: userId)
              .limit(1)
              .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw AccessTokenException('Failed to check task completion: $e');
    }
  }

  @override
  Future<TaskCompletion?> getLatestCompletionForTask(String careTaskId) async {
    try {
      final query =
          await _firestore
              .collection(_collection)
              .where('careTaskId', isEqualTo: careTaskId)
              .orderBy('completedAt', descending: true)
              .limit(1)
              .get();

      if (query.docs.isEmpty) return null;
      return _documentToTaskCompletion(query.docs.first);
    } catch (e) {
      throw AccessTokenException('Failed to get latest completion: $e');
    }
  }

  @override
  Stream<List<TaskCompletion>> watchTaskCompletionsForPet(String petId) {
    return _firestore
        .collection(_collection)
        .where('petId', isEqualTo: petId)
        .orderBy('completedAt', descending: true)
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToTaskCompletion(doc))
            .toList());
  }

  @override
  Stream<List<TaskCompletion>> watchTaskCompletionsForTask(String careTaskId) {
    return _firestore
        .collection(_collection)
        .where('careTaskId', isEqualTo: careTaskId)
        .orderBy('completedAt', descending: true)
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) => snapshot.docs
            .map((doc) => _documentToTaskCompletion(doc))
            .toList());
  }

  @override
  Stream<TaskCompletion?> watchLatestCompletionForTask(String careTaskId) {
    return _firestore
        .collection(_collection)
        .where('careTaskId', isEqualTo: careTaskId)
        .orderBy('completedAt', descending: true)
        .limit(1)
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return _documentToTaskCompletion(snapshot.docs.first);
        });
  }

  /// Convert a Firestore document to TaskCompletion.
  /// Handles both Timestamp and ISO8601 string formats for completedAt.
  TaskCompletion _documentToTaskCompletion(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw AccessTokenException('Document data is null');
    }
    final id = doc.id;

    // Handle completedAt - can be Timestamp or ISO8601 string
    DateTime completedAt;
    final completedAtValue = data['completedAt'];
    if (completedAtValue is Timestamp) {
      completedAt = completedAtValue.toDate();
    } else if (completedAtValue is String) {
      completedAt = DateTime.parse(completedAtValue);
    } else if (completedAtValue is DateTime) {
      completedAt = completedAtValue;
    } else {
      throw AccessTokenException('Invalid completedAt format: ${completedAtValue.runtimeType}');
    }

    return TaskCompletion(
      id: data['id'] as String? ?? id,
      petId: data['petId'] as String,
      careTaskId: data['careTaskId'] as String,
      completedBy: data['completedBy'] as String,
      completedAt: completedAt,
      notes: data['notes'] as String?,
      additionalData: data['additionalData'] as Map<String, dynamic>?,
    );
  }
}
