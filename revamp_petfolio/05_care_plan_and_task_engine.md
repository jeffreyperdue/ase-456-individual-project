# 05_care_plan_and_task_engine.md
Petfolio – Care Plan & Task Occurrence Engine  
LLM-Optimized Format

---

## 1. Purpose
Defines how care plans are structured, how scheduled tasks generate occurrences, how sitters complete tasks, and how notifications trigger.

---

# 2. Care Plan Structure

A **Care Plan** includes:
- Feeding schedule  
- Medication schedule  
- Notes / special instructions  
- Optional behavioral notes  
- Optional emergency contacts  

Care Plans are owned exclusively by **Owners**.

Sitters have read-only access.

---

# 3. Task Types

### **Supported task categories:**
1. **Feeding**
2. **Medication**
3. **Custom owner-created tasks** (future)
4. **Bathroom notes** (optional future)
5. **Behavioral tasks** (optional future)

All tasks generate scheduled **occurrences** based on the plan.

---

# 4. Occurrence Generation Rules

Occurrences represent *individual actionable items*.

### Example:
Feeding schedule:  
- 8:00 AM  
- 6:00 PM  

Occurrences generated:
- `occurrence_2025_01_15_08_00`
- `occurrence_2025_01_15_18_00`

---

## 4.1 Generation Strategy

### **Hard Rule:**
Occurrences should be generated dynamically **in-client**, NOT stored in Firestore long-term.

Firestore should only store:
- Completion logs  
- Notes  
- Photos  

This keeps data light and avoids needing to backfill.

---

## 4.2 When Sitter Joins Mid-Day
From your decision:

**Sitters see only future/upcoming occurrences.**

If sitter joins at 3 PM:
- 8 AM occurrence is hidden
- 6 PM occurrence is shown

---

## 4.3 Occurrence Completion Rules

Sitters can:
- Tap checkbox → mark as complete
- Add note (text)
- Add photo

Completion triggers:
- Notification event to owner
- Real-time dashboard refresh

### Completion Schema (reference):
{
"petId": "...",
"taskId": "...",
"timestampCompleted": "...",
"completedByUserId": "...",
"note": "...",
"photoUrl": "...",
}


---

# 5. Owner Editing Behavior

Owners can:
- Update care plan schedule  
- Update details  

Owners cannot:
- Edit occurrences directly  
- Modify sitter notes or photos  

Updates should apply to *future* occurrences automatically.

---

# 6. Upcoming Task Section (Optional Future)
Dashboard may show:
- “Upcoming Today”
- “Missed Tasks” (owner view only)

Not required for implementation now.

---

# 7. Notification Triggers
Whenever a sitter completes any occurrence:
- A notification is written to `/notifications`
- A banner item appears on Owner Dashboard
- Optional: push notifications

Triggered by:
- Checkbox complete
- Note added
- Photo added

---

# 8. Task List View (Sitter-Side)
Sitter side shows:
- List of tasks with today’s occurrences
- Each occurrence has:
  - Checkbox  
  - Optional note icon  
  - Optional photo icon  

Completed items should fade and display “Completed at X”.

---

# 9. Implementation Notes for LLMs

### Use:
- Riverpod for state mgmt
- Firestore `.snapshots()` for watching completion logs
- Dart DateTime for dynamic occurrence generation

### Avoid:
- Pre-generating task documents for weeks/months  
- Writing schedule conflicts without checking existing codebase  

### Ensure:
- Timezone correctness  
- Consistent timestamp formats (use UTC ideally)  

---

# End of Document
