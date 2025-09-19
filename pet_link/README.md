# ASE456 - PetLink

# PetLink – Cross-Platform Pet Care App (Flutter/Dart)

---

## 1) One-liner

A cross-platform app for pet owners, sitters, trainers, and adoption agencies to share up-to-date pet profiles, care plans, and training info — plus a lost-and-found alert system with push notifications.

---

## 2) Primary users

- Pet Owner
- Pet Sitter / Walker
- Pet Trainer
- Adoption Agency / Rescue

### Secondary users (later)

- Groomer / Vet
- Foster Parent

---

## 3) Core value props

- **Single source of truth** for a pet’s needs (diet, meds, routines, behavior, training).
- **Shareable profiles** with permissions (viewer vs editor; time-boxed links for sitters).
- **Actionable reminders** (feeding/meds/potty) via push notifications.
- **Lost & Found broadcast** within a radius with a shareable poster/QR.
- **Directory & handoff**: connect agencies ↔ owners, trainers, sitters.

---

## 4) Development timeline (two 5-week sprints)

### Sprint 1 (Weeks 1–5)

**Goal:** Ship MVP by end of Sprint.

**Core features (must-have):**

- User onboarding + Firebase Auth.
- Create/edit Pet Profile with:
    - Name, species/breed, age, weight, height.
    - Photo upload.
    - Diet + feeding schedule.
    - Medications (name, dose, time).
- Local notifications for feeding/med reminders.
- Shareable read-only profile via link/QR.

**Stretch goals:**

- Bathroom/behavioral notes.
- Emergency contacts & vet info.
- Export profile as PDF/printable handoff sheet.

### Weekly Milestones for Sprint 1

- **Week 1:**
    - Scaffold Flutter project.
    - Connect Firebase (Auth, Firestore, Storage).
    - Verify local notifications package setup.
- **Week 2:**
    - Implement user authentication (signup/login).
    - Create data models with `freezed` + JSON serialization.
    - Build Firestore rules for basic Pet ownership.
- **Week 3:**
    - Build Pet CRUD UI (create, edit, delete pet).
    - Add photo upload (Firebase Storage).
- **Week 4:**
    - Implement Care Plan form (diet, feeding schedule, meds).
    - Connect feeding/med times to local notifications.
- **Week 5:**
    - Build shareable read-only profile (link/QR).
    - End-to-end test: create pet → add care plan → receive reminder → share QR.
    - Polish UI and fix bugs.

### Sprint 2 (Weeks 6–10)

**Goal:** Expand functionality & polish.

**Core features (must-have):**

- Lost & Found mode:
    - Mark pet as lost.
    - Capture last seen location.
    - Auto-generate poster with QR.
- Basic trainer/adoption agency directory (static data).
- Add weight tracker (manual entries).
- Improve UI theming & accessibility.

**Stretch goals:**

- Push notifications for lost alerts (Firebase Cloud Messaging).
- Role-based access tokens (sitter view).
- Training logs (progress, cues, notes).
- Offline cache of pet profile (Hive).

---

## 5) Flutter architecture

- **State mgmt:** Riverpod (simple, testable).
- **Navigation:** go_router.
- **Data layer:** Repository pattern (Firestore backend).
- **Offline:** `hive` for cached profile & reminders (stretch goal).
- **Cloud:** Firebase (Auth, Firestore, Storage, Messaging).
- **Analytics/Crash:** Firebase Analytics + Crashlytics.

**Starter packages:**

- `flutter_riverpod`, `go_router`, `freezed` + `json_serializable`
- `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`
- `flutter_local_notifications`, `qr_flutter`, `image_picker`

---

## 6) Data model (initial)

- **User** { id, name, email, role[] }
- **Pet** { id, ownerId, name, species, breed, dob/age, weightKg, heightCm, photoUrl, isLost }
- **CarePlan** { id, petId, dietText, feedingSchedule[], medications[] }
- **AccessToken** { id, petId, grantedBy, role, expiresAt }
- **LostReport** { id, petId, createdAt, lastSeenGeo, notes, posterUrl }
- **WeightEntry** { id, petId, date, weightKg }

---

## 7) MVP Screens (Sprint 1)

1. **Login/Signup**
2. **Pet List/Dashboard**
3. **Pet Profile Create/Edit**
4. **Care Plan Editor (feeding + meds)**
5. **Reminder Notifications**
6. **Read-only Shared Profile View**

---

## 8) Phase roadmap (refined)

- **Sprint 1 (Weeks 1–5):** MVP complete.
- **Sprint 2 (Weeks 6–10):** Lost mode, weight tracking, directory, polish.
- **Stretch beyond class project:** advanced roles, push alerts, offline sync, trainer/adoption flows.

## 9) Success criteria

- MVP delivered by end of Sprint 1.
- At least one pet profile can be:
    1. Created.
    2. Updated with diet/med info.
    3. Generates a reminder.
    4. Shared read-only via QR.
- Sprint 2 expands into Lost & Found + extra polish.

---

## 10) Risks & mitigations

---

- **Time (3–5 hrs/week):** keep Sprint 1 tight; defer extras to Sprint 2.
- **Push notification complexity:** start local, add FCM later.
- **Privacy:** share links expire; lost posters opt-in contact info.

---

## 11) Next actions (Week 1)

- Scaffold Flutter project + Firebase init.
- Define models with `freezed`.
- Implement Pet CRUD UI.
- Add Care Plan form + schedule local reminders.
- Generate QR code for shareable profile.