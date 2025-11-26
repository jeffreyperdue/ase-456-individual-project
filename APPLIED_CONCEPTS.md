# Applied Concepts from ref_docs

This document maps the refactoring work completed to specific concepts from the course materials in `pet_link/ref_docs/course_docs/`.

---

## ✅ **Applied Concepts**

### 1. **Software Architecture** (`SWE/2. Software Architecture.md`)

**Concepts Applied:**
- ✅ **Layered Architecture**: Documented and implemented feature-first structure with clear separation:
  - `app/` (app shell, routing, theme)
  - `features/` (feature modules)
  - `services/` (cross-cutting concerns)
- ✅ **Elements, Interactions, Constraints**: Architecture explicitly defines:
  - **Elements**: Modules (features, services, app)
  - **Interactions**: How layers communicate (domain → data → application → presentation)
  - **Constraints**: Clear boundaries (presentation doesn't talk to Firestore directly)
- ✅ **MVVM Pattern**: Documented and partially implemented:
  - ViewModels (`StateNotifier`s in `application/` layer)
  - Views (widgets in `presentation/` layer)
  - Models (entities in `domain/` layer)

**Evidence:**
- `ARCHITECTURE.md` explicitly references `SWE/2. Software Architecture.md`
- Code structure follows layered architecture principles

---

### 2. **Software Design** (`SWE/3. Software Design.md`)

**Concepts Applied:**
- ✅ **Modules and Interfaces**: 
  - Each feature is a **module** with clear boundaries
  - Repository **interfaces** in `domain/` define contracts
  - Repository **implementations** in `data/` fulfill those contracts
- ✅ **Separation of Concerns**: 
  - Domain layer (business logic)
  - Data layer (infrastructure)
  - Application layer (use cases, ViewModels)
  - Presentation layer (UI only)

**Evidence:**
- Feature structure (`domain/`, `data/`, `application/`, `presentation/`) matches the "modules and interfaces" concept
- `ARCHITECTURE.md` explains this separation

---

### 3. **Refactoring Techniques** (`2. Refactoring/`)

**Concepts Applied:**
- ✅ **02 Replace Magic Number with Symbolic Constant**:
  - Replaced all magic strings with constants:
    - `'care_plans'` → `FirestoreCollections.carePlans`
    - `'onboarding_complete'` → `PrefsKeys.onboardingComplete`
    - `'/'` → `RouteNames.root`
  - Applied to: Firestore collections, SharedPreferences keys, route names

**Evidence:**
- `lib/app/config.dart` contains all constants
- All repositories, services, and navigation updated to use constants
- Directly follows the refactoring pattern from the slides

---

### 4. **Encapsulation and Dependency Injection** (`2. APIEC/04. Encapsulation and Dependency Injection.pdf`)

**Concepts Applied:**
- ✅ **Dependency Injection via Constructors**:
  - All repositories accept `FirebaseFirestore?` with defaults
  - Allows testability (can inject mock Firestore in tests)
  - Follows Dependency Inversion Principle
- ✅ **Encapsulation**:
  - Repository implementations hide Firestore details
  - Domain interfaces expose only what's needed

**Evidence:**
- `CarePlanRepositoryImpl`, `PetProfileRepositoryImpl`, `PetsRepository`, `LostReportRepository` all have injectable constructors
- Riverpod providers act as composition root

---

### 5. **MVVM Pattern** (`3. MVVM/1. MVVM Pattern in Flutter.pdf`)

**Concepts Applied:**
- ✅ **Model-View-ViewModel Structure**:
  - **Model**: Domain entities (`Pet`, `CarePlan`, `AccessToken`, etc.)
  - **View**: Widgets in `presentation/pages/` and `presentation/widgets/`
  - **ViewModel**: `StateNotifier`s in `application/` layer (e.g., `PetListNotifier`, `PetProfileFormNotifier`, `AuthNotifier`)
- ✅ **Separation**: Views read state from ViewModels, trigger actions via ViewModel methods
- ✅ **Testability**: ViewModels can be tested independently of UI

**Evidence:**
- Existing `PetListNotifier`, `AuthNotifier` follow MVVM pattern
- `ARCHITECTURE.md` documents MVVM structure
- Code structure aligns with MVVM principles (though some pages still have logic that could be extracted)

---

### 6. **SOLID Principles** (`3. SOLID/`)

**Concepts Applied:**
- ✅ **Dependency Inversion Principle (DIP)**:
  - High-level modules (application layer) depend on abstractions (repository interfaces)
  - Low-level modules (data layer) implement those abstractions
  - Example: `CarePlanRepository` interface in `domain/`, `CarePlanRepositoryImpl` in `data/`
- ✅ **Single Responsibility Principle (SRP)**:
  - Each layer has a clear responsibility:
    - Domain: Business rules
    - Data: Data access
    - Application: Use cases and state
    - Presentation: UI rendering

**Evidence:**
- Repository pattern (interface in domain, implementation in data)
- Clear layer boundaries in feature structure

---

## ⏸️ **Concepts Documented but Not Yet Fully Applied**

### 1. **Additional Refactoring Techniques** (`2. Refactoring/`)
- ⏸️ **06 Extract Method**: Could extract more logic from widgets to ViewModels
- ⏸️ **07 Extract Class**: Could extract validators from domain entities
- ⏸️ **08 Replace Type Code with Class**: Could introduce value objects for time/day-of-week

### 2. **Design Patterns** (`1. Design Patterns/`)
- ⏸️ **03 Template Method**: Could create base `FirestoreRepository<T>` class
- ⏸️ **14 Chain of Responsibility**: Could modularize `ErrorHandler` with multiple mappers
- ⏸️ **04 Factory Method**: Could use for route creation

### 3. **Testing** (`4. Tests/`)
- ⏸️ **Unit Testing**: Could add more ViewModel tests
- ⏸️ **Mock Testing**: Could add more repository mocks for testing

---

## 📊 **Summary**

**Fully Applied:**
1. ✅ Layered Architecture (SWE Architecture)
2. ✅ Modules and Interfaces (SWE Design)
3. ✅ Replace Magic Number with Constant (Refactoring)
4. ✅ Dependency Injection (APIEC)
5. ✅ MVVM Pattern Structure (MVVM)
6. ✅ SOLID Principles (DIP, SRP)

**Partially Applied:**
- MVVM: Structure exists, but some widget logic could be further extracted
- Testing: Tests exist, but could be expanded

**Documented for Future:**
- Additional refactoring techniques
- Design patterns (Template Method, Chain of Responsibility)
- Enhanced testing strategies

---

## 🎯 **Alignment with Course Goals**

The refactoring work demonstrates understanding and application of:
- **Software Architecture**: Clear layered structure
- **Software Design**: Modular design with interfaces
- **Refactoring**: Safe, behavior-preserving changes
- **MVVM**: Separation of concerns between View and ViewModel
- **SOLID**: Dependency inversion and single responsibility

All changes maintain **behavioral equivalence** while improving structure, as emphasized in the refactoring course materials.

