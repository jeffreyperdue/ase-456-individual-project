# 📅 Timeline to Google Play Launch (Sep 26 – Dec 25, 2025)

## Phase 1: Finish MVP (Now → Oct 10)
**Sprint 1, Weeks 4–5**
- Implement Care Plan form (diet, feeding schedule, medications)
- Connect feeding/med times to local notifications
- Extend Pet Profile fields (behavior, vet info, medical notes)
- Migrate from Navigator → go_router
- Build read-only shared profile (QR/link) for sitters
- End-to-end test of full MVP flow
- Basic UI polish + accessibility pass

**Deliverable:** Owner-only MVP with care plan, reminders, and QR sharing  
**Target:** Oct 11

---

## Phase 2: Sprint 2 Feature Cut & Polish (Oct 11 – Nov 10)
**Focus:** Just enough sync to show value (cut scope to hit Christmas deadline).

- Must-Have:
  - AccessToken model (family/sitter link)
  - Real-time updates for feeding/med completion (Firestore triggers)
  - Handoff flow (QR invite, auto-expire)
- Nice-to-Have (stretch goals):
  - Lost & Found mode (poster generator only)
  - Task checkoffs with simple logs

**Deliverable:** Multi-user sync foundation  
**Target:** Nov 10

---

## Phase 3: Pre-Launch Prep (Nov 11 – Dec 1)
- Internal QA on multiple Android devices
- UI/UX polish (apply chosen theme consistently)
- Security review (Firestore rules, link expiry, permissions)
- Fix major bugs only (avoid scope creep)

**Deliverable:** Release Candidate build  
**Target:** Dec 1

---

## Phase 4: Google Play Launch Readiness (Dec 1 – Dec 15)
- Set up Google Play Developer Account ($25 one-time fee)
- Generate signed release APK/AAB (Flutter + Firebase configured)
- Prepare Play Store assets:
  - App name, icon, screenshots, description
  - Privacy policy + data safety form (Firebase Auth/Firestore/Storage)
- Run internal & closed testing tracks (invite family/friends)
- Fix blocking issues reported

**Deliverable:** Store-ready build submitted for review  
**Target:** Dec 15

---

## Phase 5: Launch Window (Dec 16 – Dec 24)
- Roll out staged release (start with 20%, expand if stable)
- Monitor Firebase Crashlytics + Analytics
- Patch only critical issues

**Deliverable:** PetLink live on Play Store before Christmas  
**Target:** Dec 24

---

# 🎯 Key Success Factors
- **Scope discipline:** stick to MVP + sitter/family sync (defer pro roles, push alerts).
- **Testing:** use closed testing track early with friends/family on Android.
- **Store readiness:** prepare assets and privacy docs early.
- **Holiday buffer:** submit by Dec 15; Play reviews slow down in December.
