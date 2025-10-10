# Petfolio – Mom Test Interview Insights

## 🔑 Key Insights from Users
1. **Feeding & Med Routine Tracking**
   - Current state: Mostly memory-based; occasional pen & paper or spreadsheets.
   - Pain point: Double feeding or missed meals/meds due to lack of coordination (esp. with partners/roommates on different schedules).
   - Desired outcome: A “check-off” system where caregivers mark tasks as done.

2. **Care Handoff**
   - Current state: Written instructions, text updates, or verbal handoffs.
   - Pain point: Writing/re-writing instructions is tedious and error-prone; some sitters don’t follow rules (led to serious harm).
   - Desired outcome: A single, reliable source of truth for routines, medications, and emergency contacts.

3. **Trust & Visibility**
   - Current state: Users text/call caregivers often to confirm tasks.
   - Pain point: This creates stress and “nagging” feelings for both sides.
   - Desired outcome: Owners want passive visibility (e.g., see tasks checked off in an app, get a photo proof).

4. **Lost Pet Anxiety**
   - Current state: Pets have gone missing, users rely on neighbors/apps like Nextdoor or shelters.
   - Pain point: Scary, chaotic, and inconsistent responses.
   - Desired outcome: A structured way to mark pets missing and share info quickly.

5. **Emotional Needs**
   - Frustration: Worrying about routines and sitter reliability adds significant stress.
   - Trust gap: Users want peace of mind, not just task management.

---

## 📌 Actionable Items (Mapped to Petfolio Spec)
1. **Task Check-Off Log (Sprint 2 priority)**
   - Add a **TaskLog model** (already sketched in spec).
   - Each feeding/med is a task → caretaker checks it off → synced in real time.

2. **Care Plan Sharing Enhancements (Sprint 1 & 2)**
   - Refine **CarePlan form** (diet, feeding, meds) → link to AccessToken sharing.
   - QR/link handoff should include **vet info + emergency instructions**.

3. **Passive Monitoring for Owners**
   - Owner dashboard shows live care updates (checkmarks, timestamps).
   - Optional: Require sitter photo check-ins (stretch feature, but highly requested).

4. **Lost Pet Mode (Sprint 2)**
   - Build on **LostReport model** from spec.
   - Allow “mark as missing,” auto-generate poster, and notify linked caretakers.

5. **UX Priorities**
   - Minimize data entry overhead (users dislike rewriting instructions).
   - Care Plan should feel like a **template that can be quickly updated**.
   - Notification design: reminders for sitters, status updates for owners.

6. **Trust & Safety Features**
   - Clear logs of who completed tasks and when (avoids disputes).
   - Expiring sitter access (protects privacy).

---

## 🎯 How This Connects to the Mom Test
- You avoided “would you use this?” and got **real stories of pain points** (confusion, missed meds, lost pets).
- These are **problems users own**; you own the solution.
- Strong evidence for prioritizing:
  1. Task check-offs + sync
  2. Easier handoffs (QR, vet info)
  3. Lost pet alerts
