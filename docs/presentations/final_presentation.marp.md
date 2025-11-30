---
marp: true
theme: default
paginate: true
class: lead
size: 16:9
---

<!-- _class: lead -->

# Petfolio
## Final Project Presentation

**Cross-Platform Pet Care Application**  
Flutter • Firebase • Riverpod

---

## 📊 Key Numbers

- **122** Dart source files
- **~21,200** lines of code
- **43** test files
- **457** automated tests (100% pass rate)
- **15** major features implemented
- **6** domain models
- **10+** use cases
- **2** sprints completed (10 weeks)

---

## 📊 Development Metrics

### Sprint Completion
- **Sprint 1**: ✅ 100% complete (Weeks 1-5)
- **Sprint 2**: ✅ 100% complete (4 of 6 features, Weeks 6-10)

---
### Feature Breakdown
- **Authentication & User Management**: ✅ Complete
- **Pet Profiles & CRUD**: ✅ Complete
- **Care Plans & Scheduling**: ✅ Complete
- **Local Notifications**: ✅ Complete
- **Sharing & Access Tokens**: ✅ Complete
- **Sitter Dashboard**: ✅ Complete
- **Lost & Found Mode**: ✅ Complete
- **Onboarding Flows**: ✅ Complete

---

## 🎯 The Problem

### Coordination Challenges in Pet Care

Pet owners struggle with:
- **No single source of truth** for pet information
- **Fragmented communication** between owners, family, and sitters
- **Complex handoffs** when transferring care responsibilities
- **Missed medications or feedings** due to lack of coordination
- **Emergency situations** without quick access to critical pet data

---
### Why It Matters

- **70% of US households** own a pet (2023)
- **Pet care coordination** affects millions daily
- **Medical errors** from miscommunication can be life-threatening
- **Lost pets** need rapid information sharing

---

## 💡 The Solution: Petfolio

### Core Value Propositions

1. **Real-time Sync**
   - Shared care plans update instantly across all caregivers
   - Task completions visible to owners in real-time

2. **Role-Based Access Control**
   - Owner, co-caretaker, sitter (time-boxed), and public viewer roles
   - Secure, time-limited access tokens

---
3. **Simple Handoffs**
   - QR code or link generation for instant sharing
   - No complex setup required

4. **Single Source of Truth**
   - Diet, medications, routines, and behavior notes in one place
   - Emergency contacts and medical history always accessible

5. **Lost & Found Support**
   - One-tap "Mark as Lost" functionality
   - Auto-generated missing pet posters

---

## 🏗️ Technical Architecture

### Technology Stack

- **Frontend**: Flutter 3.x (iOS, Android, Web, Desktop)
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Notifications**: flutter_local_notifications
- **Architecture**: Clean Architecture with Feature Modules

---
### High-Level Structure

```
lib/
├── app/              # App shell, routing, theme
├── core/             # Shared widgets
├── features/         # Feature modules
│   ├── auth/
│   ├── pets/
│   ├── care_plans/
│   ├── sharing/
│   ├── lost_found/
│   └── onboarding/
└── services/         # Cross-cutting services
```

---

## 🎨 Design Patterns Applied

### 1. Factory Method Pattern

**Factory constructors** create objects with different initialization logic:

```dart
factory CarePlan.fromJson(Map<String, dynamic> json) {
  return CarePlan(
    id: json['id'] as String,
    petId: json['petId'] as String,
    // ... creates CarePlan from JSON
  );
}

factory User.fromFirebaseAuth({required FirebaseUser user}) {
  // ... creates User from Firebase auth
}
```
**Usage**: Throughout domain models for JSON/Firestore deserialization  
**Benefits**: Encapsulates object creation, supports multiple creation strategies

---


### 2. Observer Pattern

**Streams and reactive state** notify observers of changes:

```dart
// Firestore streams notify UI of data changes
Stream<List<Pet>> watchPetsForOwner(String ownerId) {
  return _firestore
    .collection('pets')
    .where('ownerId', isEqualTo: ownerId)
    .snapshots()
    .map((snapshot) => snapshot.docs.map(...).toList());
}

// Riverpod providers observe state changes
final authProvider = StreamProvider<User?>((ref) {
  return authService.authStateChanges;
});
```

**Usage**: Real-time data sync, state management with Riverpod  
**Benefits**: Decoupled components, automatic UI updates

---


### 3. Strategy Pattern

**Interchangeable algorithms** encapsulated in separate classes:

```dart
abstract class Clock {
  DateTime nowLocal();
  DateTime nowUtc();
}

class SystemClock implements Clock {
  // Uses system time
}

class FixedClock implements Clock {
  // Uses fixed time for testing
}
```

**Usage**: `Clock` abstraction allows swapping time implementations  
**Benefits**: Testability, flexibility to change time behavior

---


### 4. Facade Pattern

**Simplified interface** to complex subsystems:

```dart
class AuthService {
  // Simplifies Firebase Auth + Firestore user management
  Future<User?> signUpWithEmailAndPassword(...);
  Stream<User?> get authStateChanges;
}

class QRCodeService {
  // Simplifies QR generation, sharing, URL handling
  Widget generateQRCode({required AccessToken token});
  Future<void> shareQRCode({required AccessToken token});
}
```

**Usage**: Services like `AuthService`, `QRCodeService`, `CareScheduler`  
**Benefits**: Hides complexity, provides simple API for clients

---

## 🔧 SOLID Principles

### Single Responsibility Principle (SRP)

- **Repositories**: Only data access
- **Use Cases**: Single business operation
- **Services**: Focused functionality (e.g., `PosterGeneratorService`)

### Open/Closed Principle (OCP)

- **Abstract repository interfaces** allow extension without modification
- New implementations can be added without changing existing code

### Liskov Substitution Principle (LSP)

- **Repository implementations** are fully substitutable
- Any `CarePlanRepository` implementation works with existing code

---

## 🔧 SOLID Principles (Cont.)

### Interface Segregation Principle (ISP)

- **Focused interfaces**: `AccessTokenRepository`, `TaskCompletionRepository`
- Clients depend only on methods they use
- No "fat" interfaces

---
### Dependency Inversion Principle (DIP)

- **High-level modules** depend on abstractions (interfaces)
- **Low-level modules** implement those abstractions
- **Riverpod providers** inject dependencies

**Example**:
```dart
class SaveCarePlanUseCase {
  final CarePlanRepository _repository;  // Depends on abstraction
  SaveCarePlanUseCase(this._repository);
}
```

---

## 🏛️ Clean Architecture Layers

### Domain Layer
- **Entities**: `Pet`, `CarePlan`, `AccessToken`, `LostReport`
- **Repository Interfaces**: Abstract contracts
- **Pure business logic**, no dependencies

### Data Layer
- **Repository Implementations**: Firestore-specific code
- **DTOs**: Data transfer objects
- **External dependencies** isolated here

---
### Presentation Layer
- **Pages**: UI screens
- **Widgets**: Reusable UI components
- **Providers**: State management

### Application Layer
- **Use Cases**: Orchestrate business logic
- **Services**: Cross-cutting concerns

---

## 🔐 Security & Access Control

### Firestore Security Rules

- **Owner-only access** to pets and care plans
- **Token-based authorization** for sitters
- **Time-boxed access** with automatic expiration
- **Read-only public views** for lost pet posters

### Authentication Flow

- Firebase Auth for user identity
- `AuthWrapper` guards protected routes
- Role-based permission checking via `PermissionService`

---

## ✅ Quality Assurance

### Testing Strategy

- **Unit Tests**: Business logic, use cases, repositories
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end flows

### Test Coverage

- **457 tests** across all layers
- **100% pass rate**
- Tests for critical paths: authentication, pet CRUD, care plans, sharing

### Code Quality

- **Consistent architecture** across features
- **Type-safe** with Dart's strong typing
- **Error handling** via centralized `ErrorHandler`

---

## 📈 Project Achievements

### Completed Features

✅ User authentication & onboarding  
✅ Pet profile management with photos  
✅ Comprehensive care plans (diet, meds, schedules)  
✅ Timezone-aware local notifications  
✅ QR code & link sharing system  
✅ Sitter dashboard with task completion  
✅ Real-time task sync  
✅ Lost & Found mode with poster generation  
✅ Role-based access control  
✅ Public profile views  

---
### Technical Excellence

✅ Clean Architecture implementation  
✅ SOLID principles throughout  
✅ Repository & Use Case patterns  
✅ Comprehensive test suite  
✅ Production-ready code structure  

---

## 🚀 Future Enhancements

### Planned Features

- **Messaging System**: Owner-sitter chat
- **Push Notifications**: FCM integration
- **Weight Tracking**: Health monitoring with charts
- **Offline Support**: Local caching with Hive
- **Dark Mode**: Complete theme implementation
- **Professional Roles**: Vets, trainers, groomers

---
### Technical Improvements

- Migrate to `go_router` for declarative routing
- Enhanced error reporting with Crashlytics
- Performance optimizations
- Accessibility improvements

---

## 📝 Key Takeaways

### Problem Solved

Petfolio provides a **unified platform** for pet care coordination, eliminating communication gaps and ensuring consistent care.

### Technical Excellence

- **Clean Architecture** with clear separation of concerns
- **SOLID principles** applied consistently
- **Design patterns** (Repository, Use Case, Provider) for maintainability
- **Comprehensive testing** for reliability

---
### Impact

- **Real-world applicability**: Solves actual coordination problems
- **Scalable foundation**: Architecture supports future growth
- **Production-ready**: Code quality suitable for deployment


🐾

