# 📄 **11_riverpod_provider_templates.md**

```markdown
# 11_riverpod_provider_templates.md
Petfolio – Riverpod Provider Templates  
LLM-Optimized Format

---

## 1. Purpose
Provides **reference** Riverpod providers to guide future LLMs when implementing features.

These are **templates**, not drop-in replacements.  
LLMs should adapt them to existing provider architecture.

---

# 2. Global Role Provider

```dart
final roleProvider = StateProvider<Role>((ref) {
  return Role.owner; // default
});

enum Role { owner, sitter }
Use:

dart
Copy code
final role = ref.watch(roleProvider);
3. Stream Provider – Owner Pet List
dart
Copy code
final ownerPetsProvider = StreamProvider.autoDispose<List<Pet>>((ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) return const Stream.empty();

  final petsRef = FirebaseFirestore.instance
      .collection('pets')
      .where('ownerId', isEqualTo: userId);

  return petsRef.snapshots().map(
    (snapshot) => snapshot.docs.map((doc) => Pet.fromDoc(doc)).toList(),
  );
});
4. Stream Provider – Sitter Pet List
dart
Copy code
final sitterPetsProvider =
    StreamProvider.autoDispose<List<Pet>>((ref) async* {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) yield [];

  final tokens = await FirebaseFirestore.instance
      .collection('accessTokens')
      .where('grantedTo', isEqualTo: userId)
      .where('status', isEqualTo: 'active')
      .get();

  final petIds =
      tokens.docs.map((doc) => doc['petId'] as String).toList();

  if (petIds.isEmpty) yield [];

  yield* FirebaseFirestore.instance
      .collection('pets')
      .where('id', whereIn: petIds)
      .snapshots()
      .map((s) => s.docs.map((d) => Pet.fromDoc(d)).toList());
});
Note for LLMs:

If Firestore does not allow whereIn on id, adapt to .document(id) loops.

5. Stream Provider – Notifications
dart
Copy code
final notificationsProvider =
    StreamProvider.autoDispose<List<NotificationEvent>>((ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(3)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => NotificationEvent.fromDoc(d)).toList());
});
6. Messaging Providers
Thread List Provider
dart
Copy code
final messageThreadsProvider =
    StreamProvider.autoDispose<List<MessageThread>>((ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('messageThreads')
      .where('participants', arrayContains: userId)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(MessageThread.fromDoc).toList());
});
Messages in Thread
dart
Copy code
final messagesInThreadProvider =
    StreamProvider.family<List<Message>, String>((ref, threadId) {
  return FirebaseFirestore.instance
      .collection('messageThreads')
      .doc(threadId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((s) => s.docs.map(Message.fromDoc).toList());
});
7. Task Log Submission Provider (Notifier Template)
dart
Copy code
class TaskLogNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitTaskLog({
    required String petId,
    required String taskType,
    required String scheduledTime,
    required String note,
    required String? photoUrl,
  }) async {
    final db = FirebaseFirestore.instance;
    final user = ref.read(currentUserProvider).value!;
    final now = DateTime.now().toUtc();

    await db.collection('taskLogs').add({
      'petId': petId,
      'taskType': taskType,
      'scheduledTime': scheduledTime,
      'timestampCompleted': now,
      'completedBy': user.uid,
      'note': note,
      'photoUrl': photoUrl,
    });
  }
}

final taskLogNotifierProvider =
    AsyncNotifierProvider<TaskLogNotifier, void>(() => TaskLogNotifier());
8. Adaptation Notes for LLMs
Before using these providers:

Inspect existing providers under /lib/

Check whether project uses Notifier, StateNotifier, or ChangeNotifier

Adapt naming and folder paths accordingly

Do NOT duplicate providers if they already exist

Merge responsibly

End of Document