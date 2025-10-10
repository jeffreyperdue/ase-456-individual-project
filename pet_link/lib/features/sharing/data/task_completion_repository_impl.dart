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
      await docRef.set(completion.toJson());
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
      return TaskCompletion.fromJson(doc.data()!);
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
          .map((doc) => TaskCompletion.fromJson(doc.data()))
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
          .map((doc) => TaskCompletion.fromJson(doc.data()))
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
          .map((doc) => TaskCompletion.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw AccessTokenException('Failed to get task completions for task: $e');
    }
  }

  @override
  Future<void> updateTaskCompletion(TaskCompletion completion) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(completion.id)
          .update(completion.toJson());
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
      return TaskCompletion.fromJson(query.docs.first.data());
    } catch (e) {
      throw AccessTokenException('Failed to get latest completion: $e');
    }
  }
}
