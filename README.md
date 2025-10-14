# ASE456 – Petfolio  
**Petfolio – Cross-Platform Pet Care App (Flutter/Dart)**  

---

## 1) One-liner  
*A shared hub for pet care. Petfolio keeps owners, families, and sitters perfectly in sync with real-time schedules, reminders, and handoffs — with room to grow into adoption agencies, trainers, and professionals.*  

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

---

# Petfolio – Weekly Development Plan  

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

## Week 4 – ✅ Completed  
- ✅ Implement **Care Plan form** (diet, feeding schedule, medications)  
- ✅ Connect feeding/med times to **local notifications**  
- ✅ Extend **Pet Profile fields** with more detailed info (diet, medical, behavioral notes)  
- ✅ Build comprehensive **notification system** with permission management  
- ✅ Implement **timezone-aware scheduling** for care reminders  

---

## Week 5 – ✅ Completed  
- ✅ Build **shareable read-only profile** (QR/link) for quick handoffs  
- ✅ Create **public profile view** accessible via QR/link  
- ✅ Implement **AccessToken system** with role-based permissions  
- ✅ Build **QR code generation** and display functionality  
- ✅ Create **Sitter Dashboard** for task management  
- ✅ Implement **handoff creation and management UI**  
- ✅ Add **permission checking system** for shared access  
- ✅ Update **Firestore security rules** for token-based access  
- ✅ Conduct **end-to-end testing** of sharing workflow  

---


### Sprint 2 (Weeks 6–10) – **Essential UX & Multi-user Features**  

**Must-have:**  
- Basic onboarding improvements and welcome screen  
- Bottom navigation system for better app structure  
- Real-time sync for task completions between users  
- Lost & Found mode with basic poster generation  
- UI polish with better error handling and user feedback  

**Deferred to Future Sprints:**  
- Weight tracking system with charts and trends  
- Push notifications for task completions  
- Advanced onboarding wizard with templates  
- Dark mode support and accessibility improvements  
- Professional roles and offline support  

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
- ✅ flutter_riverpod, cloud_firestore, firebase_auth, firebase_storage, image_picker, flutter_local_notifications, qr_flutter  
- ⏳ go_router, firebase_messaging  

---

## 6) Data Model  
- ✅**User** { id, email, displayName, photoUrl, roles[], createdAt, updatedAt } ✅  
- ✅**Pet** { id, ownerId, name, species, breed, dateOfBirth, weightKg, heightCm, photoUrl, isLost, createdAt, updatedAt } ✅  
- ✅**CarePlan** { id, petId, dietText, feedingSchedule[], medications[], emergencyContacts, medicalHistory, behavioralNotes } ✅  
- ✅**AccessToken** { id, petId, grantedBy, grantedTo, role, expiresAt, notes, contactInfo } ✅  
- ⏳**TaskLog** { id, petId, taskId, completedBy, completedAt } (new, for sync)  
- ⏳**LostReport** { id, petId, createdAt, lastSeenGeo, notes, posterUrl } ⏳  
- ⏳**WeightEntry** { id, petId, date, weightKg } ⏳  

---

## 7) MVP Screens (Sprint 1)  
- ✅ Login/Signup  
- ✅ Pet List/Dashboard  
- ✅ Pet Profile Create/Edit  
- ✅ Care Plan Editor (feeding + meds)  
- ✅ Reminder Notifications  
- ✅ Read-only Shared Profile View (QR/link accessible)  
- ✅ Share Pet Page (handoff creation)  
- ✅ Sitter Dashboard (task management)  
- ✅ Public Profile View (non-authenticated access)  

---

## 8.1) Phase roadmap 

- **Sprint 1 (Weeks 1–5):** ✅ MVP complete with all core features.
- **Sprint 2 (Weeks 6–10):** Essential UX improvements and multi-user sync foundation.
- **Future Sprints:** Weight tracking, advanced notifications, professional roles, offline support.

## 8.2) Phase Roadmap (Beyond Class Project)  
- **Phase 1:** Owner MVP (profiles + reminders + QR share)  
- **Phase 2:** Family / Sitter Sync (multi-user roles, handoff links, task checkoffs)  
- **Phase 3:** Professional extensions (adoption agencies, trainers, groomers/vets)  
- **Phase 4:** Insights & reporting (health logs, exports, analytics)  
- **Phase 5:** Offline cache, advanced notifications, expanded ecosystem  

---

## 9) Success Criteria  
- Sprint 1: ✅ One owner can create a pet, add a care plan, get reminders, share QR profile.  
- Sprint 2: **Improved user experience with real-time task completion sync and Lost & Found mode.**  
- Long-term: Agencies, trainers, and vets adopt Petfolio as a trusted handoff and coordination tool.  

---

## 10) Risks & Mitigations    
- **Sync complexity:** Start with basic task completion sync; expand features later.  
- **UX complexity:** Focus on essential improvements; defer advanced features.  
- **Privacy:** ✅ Expiring share links, clear opt-in for lost posters, limited role permissions.  

---

## 10.5) MVP Status Update

**🎉 Sprint 1 MVP Complete (Week 5)**  
All core MVP functionality has been successfully implemented:

- ✅ **User Authentication** - Complete Firebase Auth with user management
- ✅ **Pet Management** - Full CRUD operations with photo upload
- ✅ **Care Planning** - Comprehensive feeding schedules and medication tracking
- ✅ **Local Notifications** - Timezone-aware reminder system with permission management
- ✅ **Enhanced Profiles** - Emergency contacts, medical history, and behavioral notes
- ✅ **Sharing System** - Access tokens, QR codes, and public profile views
- ✅ **Sitter Dashboard** - Task management for shared pet access
- ✅ **Handoff Management** - Create and manage time-boxed access tokens
- ✅ **Clean Architecture** - Production-ready code structure with proper state management

**Current Status**: Sprint 1 MVP is complete. Ready for Sprint 2 with focused UX improvements and essential multi-user features.

---

## 11) Sprint 2 Weekly Plan (Weeks 6-10)

### **Week 6: Basic Onboarding (4-5 hours)**
- Welcome screen with app overview and value proposition
- Guided first pet creation with helpful hints
- Success screen after pet creation

### **Week 7: Navigation Improvements (4-5 hours)**
- Bottom navigation bar with 3 tabs: Pets, Care, Profile
- Visual indicators for current section
- Consistent navigation across app

### **Week 8: Real-time Sync (4-5 hours)**
- Firestore real-time listeners for task completions
- Visual indicators for completed vs pending tasks
- Cross-device synchronization

### **Week 9: Lost & Found Mode (4-5 hours)**
- One-tap "Mark as Lost" functionality
- Basic poster generation with pet details
- Easy "Found" toggle and visual indicators

### **Week 10: UI Polish (4-5 hours)**
- Better error handling and user feedback
- Improved loading states and animations
- Success/error feedback for user actions

---

## 12) Future Sprint Considerations
- **Weight Tracking System** - Health monitoring with trends and charts
- **Enhanced Notifications** - Push notifications for task completions  
- **Dark Mode Support** - Complete dark theme implementation
- **Advanced Onboarding** - Multi-step wizard with templates
- **Accessibility Improvements** - WCAG compliance and screen reader support 
