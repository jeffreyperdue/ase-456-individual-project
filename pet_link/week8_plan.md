🗓 Week 8 Plan – Petfolio (Real-Time Task Sync)

Sprint 2 Theme: Multi-User Collaboration Foundation
Duration: ~4.5 hours

🎯 Week 8 Objectives

1. Implement real-time synchronization between pet owners and sitters for care tasks.
2. Add Stream-based methods to existing TaskCompletionRepository for real-time listeners.
3. Create providers that merge CareTask data with TaskCompletion status for real-time UI updates.
4. Update UI components to display completion status, timestamps, and "completedBy" user info in real-time.
5. Ensure both owner and sitter views show synchronized task completion status.

🧱 Features & User Stories

| Feature | Epic | User Stories | Status |
|---------|------|--------------|--------|
| Feature 3: Real-Time Task Completion Sync | Multi-user Collaboration | US-006, US-007, US-008 | 🟡 Planned for Week 8 |

**US-006**: As a pet owner, I want to see when my sitter completes care tasks so that I know my pet is being cared for.

**US-007**: As a pet sitter, I want to mark tasks as complete and have the owner see it so that they have peace of mind.

**US-008**: As a pet owner, I want to see which tasks are completed and which are pending so that I can track care.

**Acceptance Criteria:**
- ✅ Real-time Firestore listeners for task completions (Stream-based, not Future-based)
- ✅ UI updates immediately upon task completion (< 3 seconds)
- ✅ Completed tasks display timestamps and user who completed them
- ✅ Conflict resolution for simultaneous updates (last-write-wins with server timestamps)
- ✅ Works for both owner and sitter roles via AccessToken sharing
- ✅ Task completion status is visible in both CarePlan dashboard and individual task views

⚙️ Technical Implementation Plan

## 1. Extend TaskCompletionRepository with Stream Methods

**Current State**: Repository only has Future-based methods.
**Action**: Add Stream-based methods for real-time listening.

**File**: `lib/features/sharing/domain/task_completion_repository.dart`
**Add Methods**:
```dart
/// Watch task completions for a specific pet in real-time.
Stream<List<TaskCompletion>> watchTaskCompletionsForPet(String petId);

/// Watch task completions for a specific care task in real-time.
Stream<List<TaskCompletion>> watchTaskCompletionsForTask(String careTaskId);

/// Watch the latest completion for a specific task in real-time.
Stream<TaskCompletion?> watchLatestCompletionForTask(String careTaskId);
```

**File**: `lib/features/sharing/data/task_completion_repository_impl.dart`
**Implementation**:
```dart
@override
Stream<List<TaskCompletion>> watchTaskCompletionsForPet(String petId) {
  return _firestore
      .collection(_collection)
      .where('petId', isEqualTo: petId)
      .orderBy('completedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TaskCompletion.fromJson(doc.data()))
          .toList());
}

@override
Stream<List<TaskCompletion>> watchTaskCompletionsForTask(String careTaskId) {
  return _firestore
      .collection(_collection)
      .where('careTaskId', isEqualTo: careTaskId)
      .orderBy('completedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TaskCompletion.fromJson(doc.data()))
          .toList());
}

@override
Stream<TaskCompletion?> watchLatestCompletionForTask(String careTaskId) {
  return _firestore
      .collection(_collection)
      .where('careTaskId', isEqualTo: careTaskId)
      .orderBy('completedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return TaskCompletion.fromJson(snapshot.docs.first.data());
      });
}
```

**Note**: The existing `task_completions` collection is already being used. No new collection needed.

## 2. Create Enhanced Care Task Provider with Completion Status

**Goal**: Merge CareTask data (from CarePlan) with TaskCompletion status for real-time updates.

**File**: `lib/features/care_plans/application/care_task_provider.dart`
**Add New Provider**:
```dart
/// Enhanced care task with completion status from TaskCompletion records.
class CareTaskWithCompletion {
  final CareTask task;
  final TaskCompletion? latestCompletion;
  final bool isCompleted;
  final String? completedByUserId;
  final DateTime? completedAt;

  CareTaskWithCompletion({
    required this.task,
    this.latestCompletion,
  })  : isCompleted = latestCompletion != null,
        completedByUserId = latestCompletion?.completedBy,
        completedAt = latestCompletion?.completedAt;
}

/// Provider that combines CareTask with real-time TaskCompletion status.
final careTaskWithCompletionProvider = StreamProvider.family<
    List<CareTaskWithCompletion>, 
    ({CarePlan? carePlan, String petId})>((ref, params) {
  final carePlan = params.carePlan;
  final petId = params.petId;

  if (carePlan == null) {
    return Stream.value([]);
  }

  // Get care tasks from care plan
  final tasks = ref.read(careTasksProvider(carePlan));

  // Watch task completions for this pet
  final taskCompletionRepository = ref.read(taskCompletionRepositoryProvider);
  final completionsStream = taskCompletionRepository.watchTaskCompletionsForPet(petId);

  // Combine tasks with completion status
  return completionsStream.map((completions) {
    return tasks.map((task) {
      final completion = completions
          .where((c) => c.careTaskId == task.id)
          .firstOrNull;
      return CareTaskWithCompletion(
        task: task,
        latestCompletion: completion,
      );
    }).toList();
  });
});
```

## 3. Update UI Components for Real-Time Completion Status

**File**: `lib/features/care_plans/presentation/widgets/care_task_card.dart`

**Updates Needed**:
- Show completion checkmark when task is completed
- Display completion timestamp
- Show "completed by" user information (if available)
- Update styling for completed tasks (greyed out, checkmark icon)
- Ensure real-time updates via StreamProvider

**Key Changes**:
```dart
class CareTaskCard extends StatelessWidget {
  final CareTaskWithCompletion taskWithCompletion; // Changed from CareTask
  // ... existing fields

  // In build method:
  // - Check taskWithCompletion.isCompleted instead of task.completed
  // - Display taskWithCompletion.completedAt if completed
  // - Show completion indicator with timestamp
  // - Grey out completed tasks
}
```

**File**: `lib/features/care_plans/presentation/widgets/care_plan_dashboard.dart`

**Updates Needed**:
- Use `careTaskWithCompletionProvider` instead of `careTasksProvider`
- Display completion status in task statistics
- Show real-time updates when tasks are completed

## 4. Update Sitter Task List for Real-Time Sync

**File**: `lib/features/sharing/presentation/widgets/sitter_task_list.dart`

**Updates Needed**:
- After marking task complete, the UI should update immediately (optimistic update)
- Show completion status in real-time when owner or another sitter completes tasks
- Display "Already completed by [user]" if task was completed by someone else

## 5. Add Completion Status Display Component

**New File**: `lib/features/sharing/presentation/widgets/task_completion_status.dart`

**Purpose**: Reusable widget to show completion status with timestamp and user info.

**Features**:
- Checkmark icon for completed tasks
- Completion timestamp (relative time: "2 hours ago")
- User who completed (if available, show display name)
- Real-time updates

## 6. Update Firestore Rules (if needed)

**File**: `pet_link/firestore.rules`

**Current State**: Rules already exist for `task_completions` collection.

**Verify**:
- ✅ Sitters with valid AccessToken can create completions
- ✅ Owners can read all completions for their pets
- ✅ Real-time listeners work with current security rules

**Note**: Current rules appear sufficient. May need to verify `hasSitterAccess` function is properly implemented.

## 7. Testing & Validation

### Unit Tests
- Test Stream methods in TaskCompletionRepository
- Test CareTaskWithCompletion provider logic
- Test completion status merging

### Integration Tests
- Test real-time sync between two users
- Test simultaneous task completions
- Test completion status updates in UI

### Manual Testing
1. Log in as owner and create a pet with a care plan
2. Generate an AccessToken and log in as sitter using shared access
3. Sitter marks tasks complete → verify updates appear instantly for owner (< 3 seconds)
4. Both users see real-time status, timestamps, and sync indicator
5. Reopen app on both devices → verify data persistence and sync
6. Test with multiple tasks and multiple sitters

🧪 Validation Path

1. **Owner Setup**:
   - Log in as owner
   - Create a pet with a care plan (feeding schedule, medications)
   - Generate AccessToken for sitter
   - Navigate to Care tab and verify tasks are displayed

2. **Sitter Access**:
   - Log in as sitter (using AccessToken)
   - Navigate to sitter dashboard
   - View pet's care tasks

3. **Real-Time Sync Test**:
   - Sitter marks a task as complete
   - Owner's view should update within 3 seconds
   - Completion timestamp and user info should be visible
   - Both users should see the same completion status

4. **Persistence Test**:
   - Close and reopen app on both devices
   - Verify completion status persists
   - Verify real-time sync continues to work

🚧 Dependencies & Risks

**Dependencies**:
- ✅ Navigation and onboarding flows from Weeks 6–7 (completed)
- ✅ TaskCompletion infrastructure (already exists)
- ✅ AccessToken system (already exists)
- ✅ CarePlan and CareTask generation (already exists)

**Risks & Mitigations**:

1. **Risk**: Firestore listener redundancy or lag
   - **Mitigation**: Use `.snapshots(includeMetadataChanges: false)` to avoid duplicate events
   - **Mitigation**: Debounce UI updates if needed (unlikely for < 10 tasks)

2. **Risk**: AccessToken sync errors (expired/invalid tokens)
   - **Mitigation**: Token validity is already checked in Firestore rules
   - **Mitigation**: Add token validation check before subscribing to task streams

3. **Risk**: Performance with many tasks/completions
   - **Mitigation**: Use `.limit()` in queries where appropriate
   - **Mitigation**: Index Firestore queries properly (add composite index if needed)

4. **Risk**: CareTask ID mismatch with TaskCompletion.careTaskId
   - **Mitigation**: Ensure CareTask IDs are consistent when generating tasks
   - **Mitigation**: Add validation to match tasks with completions correctly

5. **Risk**: Real-time updates not working in UI
   - **Mitigation**: Use StreamProvider correctly with proper dependencies
   - **Mitigation**: Test with Flutter's hot reload to verify stream updates

📊 Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Sync latency | < 3 seconds | Time from task completion to UI update on other device |
| Update accuracy | 100% consistency | All users see same completion status |
| UI response | < 250 ms | Time from local task completion to UI feedback |
| Cross-user validation | Owner and sitter views remain consistent | Manual testing with two devices |
| Real-time listener performance | No lag with < 50 tasks | Monitor Firestore listener performance |

🔮 Next Week Preview (Week 9)

**Feature 4: Lost & Found Mode**
- Add "Mark as Lost" toggle and visual status indicators
- Generate shareable lost pet posters (image + text)
- Enable one-click "Found" recovery flow
- Integrate with profile view and dashboard cards

---

## 📝 Implementation Notes

### Key Architectural Decisions

1. **Use Existing Infrastructure**: Leverage existing `task_completions` collection and `TaskCompletionRepository` instead of creating new collections.

2. **Stream-Based Real-Time**: Add Stream methods to repository rather than polling with Future methods.

3. **Data Merging**: Create `CareTaskWithCompletion` model to merge CareTask (from CarePlan) with TaskCompletion status for seamless UI updates.

4. **Provider Pattern**: Use Riverpod StreamProviders for real-time updates, following existing codebase patterns.

5. **Backward Compatibility**: Ensure existing Future-based methods continue to work for non-real-time use cases.

### Code Organization

- **Repository Layer**: Add Stream methods to `TaskCompletionRepository` interface and implementation
- **Application Layer**: Create new providers in `care_task_provider.dart` for merged data
- **Presentation Layer**: Update UI components to use new providers and display completion status
- **Domain Layer**: No changes needed (models are already correct)

### Testing Strategy

1. **Unit Tests**: Test Stream methods, data merging logic
2. **Widget Tests**: Test UI components with completion status
3. **Integration Tests**: Test real-time sync between users
4. **Manual Testing**: Test with two devices to verify real-time updates
