---
marp: true
size: 4:3
paginate: true
title: Sprint 1 Review - Petfolio
---

<!-- _class: lead -->
# Sprint 1 Review
## Petfolio - Cross-Platform Pet Care App

**Jeffrey Perdue**  
ASE 456 Individual Project

---

## 🎯 What Problem This Project Aims to Solve

### The Challenge
Pet owners face **coordination difficulties** when managing pet care across multiple caregivers:
- Family members, sitters, and walkers need **real-time sync** of feeding schedules and medications
- **No single source of truth** for pet information, diet, medical history, and care routines
- **Complex handoffs** when transferring pet care responsibilities temporarily
- **Emergency situations** lack quick access to critical pet information

---

## 💡 The Solution: Petfolio

### A Shared Hub for Pet Care
- **Real-time Sync** - Shared care plans, feeding schedules, and reminders update instantly across linked users
- **Role-Based Permissions** - Owner, co-caretaker, sitter (time-boxed), and viewer roles
- **Simple Handoff** - Secure QR codes or links for sitters and temporary caregivers
- **Single Source of Truth** - Diet, medications, routines, and behavior in one trusted place
- **Lost & Found Alerts** - Broadcast missing pet info with auto-generated posters

**Vision**: Keep owners, families, and sitters perfectly in sync with real-time schedules, reminders, and handoffs

---

## 📱 Sprint 1 Demo

### Working Features Showcase

https://youtu.be/zX-gu-JBTW8

- **Authentication System** - Complete signup/login with Firebase Auth
- **Pet Management** - Full CRUD operations with photo upload
- **Care Plans** - Feeding schedules and medication tracking
- **Local Notifications** - Smart reminders for pet care tasks
- **Enhanced Profiles** - Emergency contacts and medical history

---

## 📱 Sprint 1 Demo (Continued)

### Key User Flows
1. **User Registration/Login** - Secure authentication flow
2. **Pet Creation** - Add pets with photos and detailed profiles
3. **Care Planning** - Set feeding schedules and medication reminders
4. **Notification Setup** - Configure and test local notifications
5. **Profile Management** - Edit pet information and care plans

---

## 📊 Sprint 1 Retrospective

### Project Metrics
- **Total Lines of Code**: 9,161
- **Number of Features Completed**: 5 major features
- **Number of Requirements Completed**: 5 core requirements
- **Individual Burndown Rate**: 100%

**Calculation**: (Completed Requirements / Total Requirements) × 100%

---

## ❌ What Went Wrong

### Individual Level Challenges
- **Initial Firebase Setup Complexity** - Delayed Week 1 progress due to configuration complexity
- **Web-Specific CORS Issues** - Firebase Storage required additional configuration for web platform
- **Timezone Handling** - Notifications needed multiple iterations to handle timezone differences correctly
- **Cross-Platform Testing** - Required more time for platform-specific edge cases

---

## ✅ What Went Well

### Individual Level Successes
- **Complete Authentication System** - Successfully implemented Firebase Auth with user management
- **Comprehensive Pet Management** - Built full CRUD system with photo upload functionality
- **Robust Care Plan System** - Developed scheduling with local notifications
- **Clean Architecture** - Proper separation of concerns using Riverpod state management
- **Production-Ready MVP** - Delivered all core features functional and polished

---

## 📈 Analysis & Improvement Plan

### Individual Level Insights
- **Focus on MVP First** - Defer enhancements to later sprints for better time management
- **Cross-Platform Testing** - Allocate more time for testing across different platforms
- **Error Handling** - Implement more comprehensive error handling and user feedback systems
- **Time Management** - Plan better to avoid last-minute feature additions
- **Documentation** - Create more detailed technical documentation for future development

---

## 📅 Sprint 1 Progress Summary

### Week-by-Week Breakdown
- **Week 1**: Project setup, Firebase configuration, basic Flutter app structure
- **Week 2**: Complete authentication system, user management, security rules implementation
- **Week 3**: Pet CRUD operations, photo upload, Firebase Storage integration
- **Week 4**: Care plan management, local notifications, enhanced pet profiles, MVP completion

---

## 🎯 Sprint 2 Goals

### What Will Be Accomplished
- **Basic Onboarding** - Welcome screen and guided first pet creation
- **Navigation Improvements** - Bottom navigation with clear section structure
- **Real-time Sync** - Task completion updates between pet owners and sitters
- **Lost & Found Mode** - One-tap marking and basic poster generation
- **UI Polish** - Better error handling and user feedback

---

## 📊 Sprint 2 Metrics

### Planned Deliverables 
- **Number of Features Planned**: 6 focused features
- **Number of Requirements Planned**: 15 user stories
- **Enhanced User Experience** - Better onboarding and navigation
- **Core Functionality** - Real-time sync and Lost & Found mode

---

## 📅 Sprint 2 Progress Update

### Completed Weeks
- ✅ **Week 6**: Basic onboarding improvements and welcome screen - **COMPLETE**
- ✅ **Week 7**: Navigation improvements with bottom navigation bar - **COMPLETE**

### Upcoming Weeks
- **Week 8**: Real-time sync for task completions between users
- **Week 9**: Lost & Found mode with basic poster generation
- **Week 10**: UI polish and error handling improvements

---

## ✅ Week 6 Achievements

### Onboarding System Complete
- **Welcome Screen** (US-001) - App overview with value proposition cards
- **Guided First Pet Creation** (US-002) - 3-step flow with progress indicators and contextual hints
- **Success Screen** (US-003) - Celebratory completion with next steps guidance
- **Smart State Management** - Persistent onboarding state with fallback logic for returning users

### Technical Highlights
- `LocalStorageService` - Persistent onboarding tracking using SharedPreferences
- `AppStartup` widget - Smart routing logic for new vs. returning users
- Enhanced `EditPetPage` - Guided flow mode with step indicators
- ~1,500+ lines of new code, 6 new files created

---

## ✅ Week 7 Achievements

### Navigation System Complete
- **Bottom Navigation Bar** (US-004, US-005) - 3-tab system: Pets, Care, Profile
- **Unified Navigation Shell** - `MainScaffold` with Material 3 `NavigationBar`
- **State Persistence** - Tab state saved and restored across app restarts
- **New Sections Created**:
  - `CareDashboardPage` - Action chips and FAB for task management
  - `ProfilePage` - Centralized user profile and sign out
- **Consistent Profile Access** - Top-right avatar icon on all tabs

### Technical Highlights
- `MainScaffold` - Unified app shell with IndexedStack for tab state
- `NavigationProvider` - Riverpod notifier with SharedPreferences persistence
- Integration with existing `AppStartup` and `AuthWrapper` flows
- ~500-700 lines of new code, 7 new files created

---

## 📊 Sprint 2 Progress Summary

### Completed Features (33% of Sprint 2)
- ✅ **Feature 1**: Basic Onboarding Improvements (Week 6)
  - US-001, US-002, US-003 - All complete
- ✅ **Feature 2**: Bottom Navigation System (Week 7)
  - US-004, US-005 - All complete

### Remaining Features (67% of Sprint 2)
- **Feature 3**: Real-time Task Completion Sync (Week 8)
- **Feature 4**: Lost & Found Mode (Week 9)
- **Feature 5**: Basic UI Improvements (Week 10)
- **Feature 6**: Error Handling Improvements (Week 10)

**Current Burndown Rate**: 33% (2 of 6 features, 5 of 15 user stories complete)

---

## 🎯 Key Sprint 2 Milestones

### Completed ✅
- **Week 6**: Welcome screen and guided first pet creation complete
- **Week 7**: Bottom navigation system operational

### Upcoming
- **Week 8**: Real-time task completion sync working
- **Week 9**: Lost & Found mode functional with basic poster generation
- **Week 10**: UI polish and error handling improvements complete

---

## 🏆 Sprint 1 Achievements

### MVP Complete ✅
- **Authentication**: Secure user management with Firebase
- **Pet Profiles**: Complete CRUD with photo upload
- **Care Plans**: Feeding schedules and medication tracking
- **Notifications**: Local reminder system with permissions
- **Architecture**: Clean, scalable code structure

---

## 🚀 Next Steps

### Sprint 2 Remaining Work 
1. ✅ **User Experience** - Better onboarding and navigation - **COMPLETE**
2. **Real-time Collaboration** - Task completion sync between users (Week 8)
3. **Lost & Found Mode** - Critical emergency feature for pet owners (Week 9)
4. **UI Polish** - Better error handling and user feedback (Week 10)
5. **Foundation** - Build on solid MVP with essential improvements - **IN PROGRESS**

**Weeks 6-7 complete! Ready for real-time sync and Lost & Found features.**

---

## 📈 Project Status

### Current State
- **Sprint 1**: ✅ **COMPLETE** - All MVP features delivered
- **Sprint 2**: 🚧 **IN PROGRESS** - 33% complete (Weeks 6-7 done)
- **Code Quality**: Production-ready with clean architecture
- **User Experience**: Enhanced with onboarding and navigation improvements
- **Platform Support**: Android, iOS, and Web compatibility

**Sprint 2 on track with onboarding and navigation foundation established!**

---

## 📋 Sprint 2 Success Criteria

### Realistic Goals
- **User Experience**: Better onboarding and navigation clarity
- **Multi-user Sync**: Real-time task completion updates
- **Lost & Found**: Functional emergency pet marking
- **UI Polish**: Improved error handling and user feedback
- **Foundation**: Solid base for future enhancements

**Focus on high-impact, achievable improvements!**
