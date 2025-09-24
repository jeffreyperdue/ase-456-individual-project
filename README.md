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

- **Week 1:** ✅ **COMPLETED**
    - ✅ Scaffold Flutter project.
    - ✅ Connect Firebase (Auth, Firestore, Storage).
    - ✅ Verify local notifications package setup.
- **Week 2:** ✅ **COMPLETED**
    - ✅ Implement user authentication (signup/login).
    - ✅ Create data models with User domain model.
    - ✅ Build Firestore rules for basic Pet ownership.
    - ✅ Migrate to Riverpod state management.
    - ✅ Implement AuthWrapper for protected routes.
- **Week 3:** ✅ **COMPLETED**
    - ✅ Build Pet CRUD UI (create, edit, delete pet)
    - ✅ Photo upload (Firebase Storage) with web/mobile support
    - ✅ Published Firestore & Storage rules (owner-only access)
    - ⏳ Enhanced pet profile fields (extend in Week 4)
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

- **State mgmt:** ✅ Riverpod (simple, testable) - **IMPLEMENTED**
- **Navigation:** ⏳ go_router (currently using basic Navigator)
- **Data layer:** ✅ Repository pattern (Firestore backend) - **IMPLEMENTED**
- **Authentication:** ✅ Firebase Auth with user management - **IMPLEMENTED**
- **Offline:** `hive` for cached profile & reminders (stretch goal).
- **Cloud:** ✅ Firebase (Auth, Firestore) - **PARTIALLY IMPLEMENTED**
- **Analytics/Crash:** Firebase Analytics + Crashlytics.

**Current packages:**

- ✅ `flutter_riverpod`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `image_picker` - **IMPLEMENTED**
- ⏳ `go_router`, `firebase_messaging` - **PENDING**
- ⏳ `flutter_local_notifications`, `qr_flutter` - **PENDING**

---

## 6) Data model (current status)

- ✅ **User** { id, email, displayName, photoUrl, roles[], createdAt, updatedAt } - **IMPLEMENTED**
- ✅ **Pet** { id, ownerId, name, species, breed, dateOfBirth, weightKg, heightCm, photoUrl, isLost, createdAt, updatedAt } - **IMPLEMENTED**
- ⏳ **CarePlan** { id, petId, dietText, feedingSchedule[], medications[] } - **PENDING**
- ⏳ **AccessToken** { id, petId, grantedBy, role, expiresAt } - **PENDING**
- ⏳ **LostReport** { id, petId, createdAt, lastSeenGeo, notes, posterUrl } - **PENDING**
- ⏳ **WeightEntry** { id, petId, date, weightKg } - **PENDING**

---

## 7) MVP Screens (Sprint 1)

1. ✅ **Login/Signup** - **IMPLEMENTED**
2. ✅ **Pet List/Dashboard** - **IMPLEMENTED**
3. ✅ **Pet Profile Create/Edit** - **IMPLEMENTED**
4. ⏳ **Care Plan Editor (feeding + meds)** - **PENDING**
5. ⏳ **Reminder Notifications** - **PENDING**
6. ⏳ **Read-only Shared Profile View** - **PENDING**

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

## 11) Next actions (Week 3 - Current Priority)

### Immediate (This Week)
- ✅ **Photo Upload**: Implement Firebase Storage integration for pet photos
- ⏳ **Enhanced Pet Profile**: Add more detailed pet information fields (diet, medical info, etc.)
- ⏳ **Care Plan Model**: Create CarePlan data model and Firestore integration
- ⏳ **Care Plan UI**: Build forms for diet, feeding schedule, and medications

### Week 4 Goals
- ⏳ **Local Notifications**: Implement `flutter_local_notifications` for feeding/med reminders
- ⏳ **Care Plan Integration**: Connect care plan data to notification scheduling
- ⏳ **Navigation Upgrade**: Migrate from basic Navigator to `go_router` for better routing

### Week 5 Goals (Sprint 1 Completion)
- ⏳ **QR Code Generation**: Implement `qr_flutter` for shareable pet profiles
- ⏳ **Read-only Profile View**: Create public profile page accessible via QR/link
- ⏳ **End-to-end Testing**: Complete user journey from pet creation to shared profile
- ⏳ **UI Polish**: Improve theming, accessibility, and user experience

