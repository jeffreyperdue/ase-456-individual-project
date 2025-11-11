# Week 8 Manual Testing Guide

**Feature:** Real-Time Task Completion Sync  
**Duration:** ~30-45 minutes  
**Requirements:** Two devices or browser tabs, two user accounts

---

## 🎯 Testing Objectives

Verify that:
1. Real-time synchronization works between pet owners and sitters
2. Task completion status updates immediately (< 3 seconds)
3. Completion timestamps and user information are displayed correctly
4. Dashboard shows completion statistics in real-time
5. User display names are shown for completed tasks
6. Both owner and sitter views stay synchronized

---

## 📋 Prerequisites

### Setup Requirements

1. **Two User Accounts**
   - **Owner Account**: Main pet owner account
   - **Sitter Account**: Pet sitter account (can use a test account)

2. **Two Devices/Browser Tabs**
   - Option A: Two separate devices (phone + computer, or two phones)
   - Option B: Two browser tabs in incognito/private mode (different accounts)

3. **Test Pet with Care Plan**
   - At least one pet with a care plan
   - Care plan should have multiple tasks (feeding schedules, medications)
   - Tasks should include some that are due today or soon

4. **AccessToken Setup**
   - Owner must generate an AccessToken for the sitter
   - Sitter must use the AccessToken to access the pet

---

## 🧪 Test Scenarios

### Test 1: Real-Time Task Completion Sync (Core Functionality)

**Objective:** Verify that task completion updates appear in real-time on both devices.

#### Setup
1. **Owner Device:**
   - Log in as owner
   - Navigate to pet detail page or care plan view
   - Keep the page open and visible

2. **Sitter Device:**
   - Log in as sitter
   - Navigate to sitter dashboard
   - Access the pet using the AccessToken

#### Steps
1. On **Sitter Device**: Find an incomplete task
2. Click "Mark Complete" button on a task
3. Observe on **Owner Device**: Task should update to completed status within 3 seconds
4. Verify on **Owner Device**: 
   - Task shows checkmark icon
   - Task is greyed out/strikethrough
   - Completion timestamp is displayed
   - User who completed is shown (sitter's name)

#### Expected Results
- ✅ Task completion appears on owner device within 3 seconds
- ✅ Completion status is visually clear (checkmark, greyed out)
- ✅ Timestamp shows relative time ("just now", "2 minutes ago")
- ✅ Sitter's display name is shown (or email if no display name)

#### Troubleshooting
- **Not updating**: Check network connection, verify Firestore rules allow read access
- **Slow updates**: Check internet speed, verify Firestore listener is active
- **No user name**: Verify sitter account has display name set, or email should show

---

### Test 2: Completion Status Display in Dashboard

**Objective:** Verify that completion statistics appear in the Care Plan Dashboard.

#### Setup
1. Log in as owner
2. Navigate to home page (should show Care Plan Dashboard)

#### Steps
1. Check the dashboard for completion statistics
2. Have sitter complete a task (from Test 1)
3. Observe dashboard updates in real-time
4. Verify completed and pending counts update

#### Expected Results
- ✅ Dashboard shows "Completed" and "Pending" stat cards
- ✅ Completed count increases when tasks are completed
- ✅ Pending count decreases when tasks are completed
- ✅ Statistics update in real-time (within 3 seconds)

#### Verification Points
- **Before completion**: Note the completed/pending counts
- **After completion**: Counts should update automatically
- **Multiple tasks**: Complete multiple tasks and verify counts update correctly

---

### Test 3: User Display Names in Completion Status

**Objective:** Verify that user display names are shown for completed tasks.

#### Setup
1. Ensure sitter account has a display name set
2. Log in as owner
3. Navigate to care plan view page

#### Steps
1. Have sitter complete a task
2. Check the task card on owner device
3. Verify the completion status shows:
   - Sitter's display name (if set)
   - Or sitter's email (if no display name)
   - Completion timestamp

#### Expected Results
- ✅ Completed tasks show "Completed by [Display Name] [time ago]"
- ✅ If no display name, shows email address
- ✅ Timestamp is relative ("just now", "5 minutes ago")
- ✅ User name updates if sitter changes their display name

#### Edge Cases to Test
- **No display name**: Should show email address
- **Multiple users**: Have different sitters complete tasks, verify correct names
- **Owner completes task**: Verify owner's name shows correctly

---

### Test 4: Task Completion in Sitter Dashboard

**Objective:** Verify that sitter can see completion status and complete tasks.

#### Setup
1. Log in as sitter
2. Navigate to sitter dashboard
3. Access pet using AccessToken

#### Steps
1. View the task list
2. Complete a task by clicking "Mark Complete"
3. Verify the task updates to completed status
4. Check that completed tasks show:
   - Checkmark icon
   - Completion timestamp
   - "Completed [time ago]" message
5. Verify completed tasks are filtered out from action list (only incomplete tasks show "Mark Complete" button)

#### Expected Results
- ✅ Sitter can mark tasks as complete
- ✅ Completed tasks show completion status immediately
- ✅ Completed tasks are visually distinct (greyed out, checkmark)
- ✅ Completed tasks don't show "Mark Complete" button
- ✅ Completion timestamp is accurate

---

### Test 5: Real-Time Sync with Multiple Tasks

**Objective:** Verify that multiple task completions sync correctly in real-time.

#### Setup
1. Ensure pet has at least 3-5 tasks
2. Set up owner and sitter devices as in Test 1

#### Steps
1. **Sitter Device**: Complete task #1
2. **Owner Device**: Verify task #1 shows as completed
3. **Sitter Device**: Complete task #2
4. **Owner Device**: Verify task #2 shows as completed
5. **Owner Device**: Complete task #3
6. **Sitter Device**: Verify task #3 shows as completed (if sitter has view permissions)

#### Expected Results
- ✅ All task completions sync in real-time
- ✅ No tasks are missed or duplicated
- ✅ Completion order is preserved (latest completion shows)
- ✅ Multiple completions don't cause UI flickering or errors

---

### Test 6: Completion Status in Care Plan View Page

**Objective:** Verify that care plan view page shows completion status correctly.

#### Setup
1. Log in as owner
2. Navigate to pet detail page
3. Open care plan view page

#### Steps
1. Check that tasks are organized into sections:
   - Urgent Tasks (overdue, due soon)
   - Today's Tasks
   - Upcoming Tasks
2. Have sitter complete tasks in different categories
3. Verify that:
   - Completed tasks show completion status
   - Completed tasks are filtered out from "incomplete" lists
   - User display names are shown
   - Real-time updates work for all sections

#### Expected Results
- ✅ Tasks are organized correctly by urgency
- ✅ Completed tasks show completion status with user names
- ✅ Completed tasks don't appear in "incomplete" task lists
- ✅ Real-time updates work across all sections
- ✅ Completion status is consistent across all views

---

### Test 7: Dashboard Statistics Accuracy

**Objective:** Verify that dashboard statistics are accurate and update in real-time.

#### Setup
1. Log in as owner
2. Note the current statistics in the dashboard:
   - Total tasks
   - Completed tasks
   - Pending tasks
   - Today's tasks

#### Steps
1. Complete a task (as owner or sitter)
2. Verify dashboard statistics update:
   - Completed count increases by 1
   - Pending count decreases by 1
   - Total tasks remains the same
3. Complete multiple tasks
4. Verify statistics update correctly for each completion

#### Expected Results
- ✅ Statistics are accurate (match actual task counts)
- ✅ Statistics update in real-time (within 3 seconds)
- ✅ Completed + Pending = Total tasks
- ✅ Statistics are consistent across page refreshes

---

### Test 8: Simultaneous Task Completions (Conflict Resolution)

**Objective:** Verify that simultaneous completions are handled correctly.

#### Setup
1. Set up owner and sitter devices
2. Find a task that both can complete (if permissions allow)

#### Steps
1. **Owner Device**: Click "Mark Complete" on a task
2. **Sitter Device**: Simultaneously click "Mark Complete" on the same task
3. Observe which completion is recorded
4. Verify that both devices show the same completion status

#### Expected Results
- ✅ Last write wins (Firestore server timestamp determines winner)
- ✅ Both devices eventually show the same completion status
- ✅ No errors or conflicts in the UI
- ✅ Completion is recorded correctly in Firestore

---

### Test 9: App Restart and Persistence

**Objective:** Verify that completion status persists after app restart.

#### Setup
1. Complete some tasks as sitter
2. Verify owner sees completions

#### Steps
1. **Owner Device**: Close and reopen the app
2. Navigate to care plan view
3. Verify that completed tasks still show as completed
4. Verify that completion timestamps are preserved
5. Verify that user names are still displayed

#### Expected Results
- ✅ Completion status persists after app restart
- ✅ Timestamps are preserved correctly
- ✅ User names are still displayed
- ✅ Real-time sync continues to work after restart

---

### Test 10: Multiple Pets and Multiple Sitters

**Objective:** Verify that completion status works correctly with multiple pets and sitters.

#### Setup
1. Create multiple pets with care plans
2. Generate AccessTokens for multiple sitters
3. Have different sitters access different pets

#### Steps
1. **Sitter 1**: Complete tasks for Pet 1
2. **Owner**: Verify Pet 1 tasks show completion from Sitter 1
3. **Sitter 2**: Complete tasks for Pet 2
4. **Owner**: Verify Pet 2 tasks show completion from Sitter 2
5. Verify that completions don't mix between pets
6. Verify that dashboard shows correct statistics for all pets

#### Expected Results
- ✅ Completions are pet-specific (no mixing)
- ✅ User names are correct for each completion
- ✅ Dashboard aggregates statistics correctly across all pets
- ✅ Real-time updates work independently for each pet

---

## 🔍 Verification Checklist

Use this checklist to ensure all features are tested:

### Core Functionality
- [ ] Real-time task completion sync works (< 3 seconds)
- [ ] Completion status displays correctly (checkmark, greyed out)
- [ ] Completion timestamps are shown and accurate
- [ ] User display names are shown for completed tasks
- [ ] Completion status persists after app restart

### Dashboard
- [ ] Dashboard shows completion statistics
- [ ] Completed and pending counts are accurate
- [ ] Statistics update in real-time
- [ ] Statistics are consistent across page refreshes

### User Experience
- [ ] Sitter can mark tasks as complete
- [ ] Owner sees completions in real-time
- [ ] Completed tasks are filtered from action lists
- [ ] User names are displayed correctly (or email fallback)
- [ ] Completion status is visible in all views (dashboard, detail, care plan)

### Edge Cases
- [ ] Multiple simultaneous completions are handled correctly
- [ ] Multiple pets and sitters work correctly
- [ ] No display name falls back to email
- [ ] Task completion works for both owner and sitter roles
- [ ] Real-time updates work with poor network conditions

---

## 🐛 Troubleshooting Guide

### Issue: Task completion not updating in real-time

**Possible Causes:**
1. Firestore rules don't allow read access
2. Network connection issues
3. Firestore listener not active
4. Provider not subscribed correctly

**Solutions:**
1. Check Firestore rules allow read access for `task_completions` collection
2. Check network connection and internet speed
3. Verify StreamProvider is being watched in UI
4. Check browser console for errors
5. Verify Firestore is connected and working

### Issue: User display names not showing

**Possible Causes:**
1. User doesn't have display name set
2. User provider not fetching correctly
3. Firestore rules don't allow user read access

**Solutions:**
1. Check if user has display name in Firestore `users` collection
2. Verify `userDisplayNamesProvider` is being used correctly
3. Check Firestore rules allow read access for `users` collection
4. Check browser console for errors in user fetching

### Issue: Dashboard statistics not updating

**Possible Causes:**
1. Completion-aware provider not being used
2. Provider not subscribed correctly
3. Statistics calculation error

**Solutions:**
1. Verify `allPetsWithPlanCompletionProvider` is being used
2. Check that provider is being watched in dashboard widget
3. Verify completion statistics are being calculated correctly
4. Check browser console for errors

### Issue: Completion status not persisting after restart

**Possible Causes:**
1. Data not being saved to Firestore
2. Firestore rules don't allow write access
3. Task completion not being created correctly

**Solutions:**
1. Check Firestore console to verify completions are being saved
2. Check Firestore rules allow write access for sitters
3. Verify `createTaskCompletion` is being called correctly
4. Check browser console for errors

---

## 📊 Test Results Template

Use this template to record test results:

```
Test Date: ___________
Tester: ___________
Environment: ___________

Test 1: Real-Time Task Completion Sync
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 2: Completion Status Display in Dashboard
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 3: User Display Names in Completion Status
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 4: Task Completion in Sitter Dashboard
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 5: Real-Time Sync with Multiple Tasks
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 6: Completion Status in Care Plan View Page
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 7: Dashboard Statistics Accuracy
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 8: Simultaneous Task Completions
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 9: App Restart and Persistence
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Test 10: Multiple Pets and Multiple Sitters
- Status: ✅ Pass / ❌ Fail
- Notes: ___________

Overall Status: ✅ All Tests Pass / ⚠️ Some Tests Fail
Issues Found: ___________
```

---

## 🎯 Success Criteria

All tests should pass with the following criteria:

1. **Real-time Sync**: Task completions appear on other devices within 3 seconds
2. **Accuracy**: Completion status is accurate and consistent
3. **User Attribution**: User names are displayed correctly
4. **Persistence**: Completion status persists after app restart
5. **Statistics**: Dashboard statistics are accurate and update in real-time
6. **User Experience**: UI is responsive and provides clear feedback

---

## 📝 Notes

- Test with both good and poor network conditions
- Test with multiple browsers/devices
- Test with different user roles (owner, sitter)
- Test with multiple pets and care plans
- Document any issues or edge cases found
- Verify Firestore rules are working correctly
- Check browser console for any errors or warnings

---

**Last Updated:** After Week 8 Implementation  
**Status:** Ready for Testing

