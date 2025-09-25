# ASE456 – PetLink  
**PetLink – Cross-Platform Pet Care App (Flutter/Dart)**  

---

## 1) One-liner  
*A shared hub for pet care. PetLink keeps owners, families, and sitters perfectly in sync with real-time schedules, reminders, and handoffs — with room to grow into adoption agencies, trainers, and professionals.*  

---

## 2) Primary Users  

**Now (MVP + Sync focus):**  
- Pet Owner (Admin)  
- Family / Roommates (Co-caretakers)  
- Pet Sitter / Walker (Temporary role)  

**Later (professional roles):**  
- Adoption Agency / Rescue  
- Dog Trainer  
- Groomer / Vet  
- Foster Parent  

---

## 3) Core Value Propositions  
- **Real-time sync** – shared care plans, feeding/meds, and reminders update instantly across linked users.  
- **Role-based permissions** – owner, co-caretaker, sitter (time-boxed), viewer.  
- **Simple handoff** – generate a secure QR or link for sitters and temporary caregivers.  
- **Single source of truth** – diet, meds, routines, and behavior in one trusted place.  
- **Lost & Found alerts** – broadcast missing pet info within a radius, with auto-generated posters.  
- **Professional extensions** – agencies manage handoffs, trainers log progress, vets/groomers view health notes.  

---

## 4) Development Timeline (Two 5-week sprints)  

### Sprint 1 (Weeks 1–5) – **Owner MVP**  
Goal: Ship core app for owners by end of Sprint.  

**Must-have:**  
- User onboarding + Firebase Auth  
- Create/edit Pet Profile (name, species, breed, age, weight, height, photo)  
- Care Plan form (diet, feeding schedule, meds)  
- Local notifications (feeding/med reminders)  
- Read-only profile (QR/link share)  

**Stretch:**  
- Bathroom/behavioral notes  
- Emergency contacts & vet info  
- Export profile (PDF handoff sheet)  

---

# PetLink – Weekly Development Plan  

---

## Week 1 – ✅ Completed  
- ✅ Scaffold Flutter project  
- ✅ Connect Firebase (Auth, Firestore, Storage)  
- ✅ Verify local notifications package setup  

---

## Week 2 – ✅ Completed  
- ✅ Implement user authentication (signup/login)  
- ✅ Create data models with User domain model  
- ✅ Build Firestore rules for basic Pet ownership  
- ✅ Migrate to Riverpod state management  
- ✅ Implement AuthWrapper for protected routes  

---

## Week 3 – ✅ Completed  
- ✅ Build Pet CRUD UI (create, edit, delete pet)  
- ✅ Photo upload (Firebase Storage) with web/mobile support  
- ✅ Publish Firestore & Storage rules (owner-only access)  
- ⏳ Enhanced Pet Profile fields (extend in Week 4)  

---

## Week 4 – Current Goals  
- ⏳ Implement **Care Plan form** (diet, feeding schedule, medications)  
- ⏳ Connect feeding/med times to **local notifications**  
- ⏳ Extend **Pet Profile fields** with more detailed info (diet, medical, behavioral notes)  
- ⏳ Begin migration from **Navigator → go_router** for cleaner routing  
- ⏳ Lay groundwork for **AccessToken model** (role-based sharing, sitter/family sync)  

---

## Week 5 – Upcoming Goals  
- ⏳ Build **shareable read-only profile** (QR/link) for quick handoffs  
- ⏳ Create **public profile view** accessible via QR/link  
- ⏳ Conduct **end-to-end test**:  
  1. Create pet  
  2. Add care plan  
  3. Receive reminder  
  4. Share profile with sitter/family  
- ⏳ Introduce first **handoff concept** (time-boxed link, sitter preview role)  
- ⏳ **Polish UI/UX** (theming, accessibility, bug fixes)  

---


### Sprint 2 (Weeks 6–10) – **Sync Foundation**  
Goal: Expand to multi-user care.  

**Must-have:**  
- AccessToken model for role-based sharing  
- Real-time updates on care plan tasks (feeding/med checkoffs)  
- Handoff flow for sitters (QR invite, auto-expire)  
- Notifications for completed tasks (sitter → owner updates)  
- Lost & Found mode (mark pet lost, last seen location, poster generator)  

**Stretch:**  
- Push notifications for lost alerts (Firebase Cloud Messaging)  
- Role-based trainer/adoption roles  
- Training logs (progress, cues, notes)  
- Offline cache with Hive  

---

## 5) Flutter Architecture  
- **State mgmt:** ✅ Riverpod (simple, testable) - **IMPLEMENTED**
- **Navigation:** ⏳ go_router (currently using basic Navigator)
- **Data layer:** ✅ Repository pattern (Firestore backend) - **IMPLEMENTED**
- **Authentication:** ✅ Firebase Auth with user management - **IMPLEMENTED**
- **Offline:** `hive` for cached profile & reminders (stretch goal).
- **Cloud:** ✅ Firebase (Auth, Firestore) - **PARTIALLY IMPLEMENTED**
- **Analytics/Crash:** Firebase Analytics + Crashlytics.

**Packages:**  
- ✅ flutter_riverpod, cloud_firestore, firebase_auth, firebase_storage, image_picker  
- ⏳ go_router, firebase_messaging, flutter_local_notifications, qr_flutter  

---

## 6) Data Model  
- ✅**User** { id, email, displayName, photoUrl, roles[], createdAt, updatedAt } ✅  
- ✅**Pet** { id, ownerId, name, species, breed, dateOfBirth, weightKg, heightCm, photoUrl, isLost, createdAt, updatedAt } ✅  
- ⏳**CarePlan** { id, petId, dietText, feedingSchedule[], medications[] } ⏳  
- ⏳**AccessToken** { id, petId, grantedBy, role, expiresAt } ⏳  
- ⏳**TaskLog** { id, petId, taskId, completedBy, completedAt } (new, for sync)  
- ⏳**LostReport** { id, petId, createdAt, lastSeenGeo, notes, posterUrl } ⏳  
- ⏳**WeightEntry** { id, petId, date, weightKg } ⏳  

---

## 7) MVP Screens (Sprint 1)  
- ✅ Login/Signup  
- ✅ Pet List/Dashboard  
- ✅ Pet Profile Create/Edit  
- ⏳ Care Plan Editor (feeding + meds)  
- ⏳ Reminder Notifications  
- ⏳ Read-only Shared Profile View  

---

## 8.1) Phase roadmap (refined)

- **Sprint 1 (Weeks 1–5):** MVP complete.
- **Sprint 2 (Weeks 6–10):** Lost mode, weight tracking, directory, polish.
- **Stretch beyond class project:** advanced roles, push alerts, offline sync, trainer/adoption flows.

## 8.2) Phase Roadmap (Beyond Class Project)  
- **Phase 1:** Owner MVP (profiles + reminders + QR share)  
- **Phase 2:** Family / Sitter Sync (multi-user roles, handoff links, task checkoffs)  
- **Phase 3:** Professional extensions (adoption agencies, trainers, groomers/vets)  
- **Phase 4:** Insights & reporting (health logs, exports, analytics)  
- **Phase 5:** Offline cache, advanced notifications, expanded ecosystem  

---

## 9) Success Criteria  
- Sprint 1: One owner can create a pet, add a care plan, get reminders, share QR profile.  
- Sprint 2: **Two linked accounts can see and complete the same care plan in real time.**  
- Long-term: Agencies, trainers, and vets adopt PetLink as a trusted handoff and coordination tool.  

---

## 10) Risks & Mitigations  
- **Time (4–6 hrs/week):** keep MVP tight; defer stretch goals.  
- **Sync complexity:** start simple with AccessToken + real-time updates; refine roles later.  
- **Push notifications:** begin with local, layer in FCM once core sync works.  
- **Privacy:** expiring share links, clear opt-in for lost posters, limited role permissions.  

---

## 11) Next Actions (Week 4 Goals)    
- ⏳ Implement **Care Plan form** (diet, feeding schedule, medications)  
- ⏳ Connect feeding/med times to **local notifications**  
- ⏳ Extend **Pet Profile fields** with more detailed info (diet, medical, behavioral notes)  
- ⏳ Begin migration from **Navigator → go_router** for cleaner routing  
- ⏳ Lay groundwork for **AccessToken model** (role-based sharing, sitter/family sync) 
