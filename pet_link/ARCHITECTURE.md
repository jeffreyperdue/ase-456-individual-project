## Petfolio Architecture Overview

This document explains the high-level architecture of the Petfolio app and how the codebase is organized.  
It is aligned with the course materials in `ref_docs` (Software Architecture, Software Design, MVVM, SOLID, Refactoring, and Testing).

The goal is to keep the app **behaviorally identical** while making the structure easier to understand, maintain, and test.

---

## Top-Level Structure

- `lib/main.dart`
  - Entry point that initializes Flutter, Firebase, timezone data, and wraps the app in a Riverpod `ProviderScope`.
- `lib/app/`
  - App shell: Material app, routes, app startup logic, theme, shared widgets and utilities.
- `lib/features/`
  - Feature modules (auth, pets, care_plans, sharing, lost_found, onboarding).
  - Each feature is organized by layers: **domain**, **data**, **application**, **presentation**.
- `lib/services/`
  - Cross-cutting services, not owned by a single feature (e.g., `LocalStorageService`, `ErrorHandler`, `NetworkService`).
- `test/`
  - Unit, widget, and integration tests organized by layer and feature.

This follows a **layered architecture** and **feature-first** grouping, as described in the Software Architecture slides (`SWE/2. Software Architecture.md`).

---

## Layers per Feature

Each feature under `lib/features/<feature_name>/` is structured into layers that roughly match **MVVM** and **clean architecture** concepts:

- `domain/`
  - **What** the feature is about (business concepts and rules).
  - Contains:
    - Entities and value objects (e.g., `CarePlan`, `Pet`, `AccessToken`).
    - Repository interfaces (e.g., `CarePlanRepository`, `PetProfileRepository`).
    - Domain services where needed (pure logic without UI or IO).

- `data/`
  - **How** the app talks to external systems (Firestore, Storage, etc.).
  - Contains:
    - Repository implementations (e.g., `CarePlanRepositoryImpl`, `PetProfileRepositoryImpl`, `PetsRepository`).
    - Data transfer objects and Firestore/Storage adapters.
  - Uses dependency injection (DI) via constructors and Riverpod providers so that tests can swap implementations.

- `application/`
  - **Use cases** and **state management** for the feature.
  - Contains:
    - Use cases (e.g., `SaveCarePlanUseCase`, `GenerateCareTasksUseCase`, sharing and auth use cases).
    - Riverpod `StateNotifier`s and providers that act like **ViewModels** in MVVM.
  - Bridges between domain objects and presentation layer (no direct widgets or BuildContext here).

- `presentation/`
  - **UI layer**: screens and widgets only.
  - Contains:
    - `pages/` – full screens routed by the app.
    - `widgets/` – reusable UI components for that feature.
    - `state/` – small UI-specific providers when needed.
  - Reads data from ViewModels/providers and renders it; delegates user actions back to ViewModels.
  - Should not talk directly to Firestore or low-level services.

This structure maps to the **Model–View–ViewModel (MVVM)** pattern introduced in the MVVM slides (`ref_docs/course_docs/3. MVVM/`).

---

## Cross-Cutting Concerns

- **Error Handling**
  - Centralized in `lib/services/error_handler.dart`.
  - Maps technical errors (Firebase, timeouts, network issues) to clear, user-friendly messages, matching the testing guide.
  - Called from ViewModels and UI when operations fail.

- **Local Storage & Onboarding Flags**
  - `lib/services/local_storage_service.dart` provides access to SharedPreferences-backed flags (e.g., onboarding complete, has seen welcome).
  - Accessed through Riverpod providers for testability.

- **Network Connectivity**
  - `lib/services/network_service.dart` provides basic network connectivity checks and messages.
  - Can be wrapped or extended by a connectivity abstraction used in use cases.

- **Routes & Navigation**
  - `lib/app/app.dart` defines the `MaterialApp`, routes, and `onGenerateRoute` for argument-passing screens (e.g., edit pet, share pet, public profile).
  - Navigation logic is kept separate from business logic.

---

## Testing Strategy

The test layout supports the architecture:

- `test/unit/domain/`
  - Tests domain entities and domain logic (pure Dart, no Flutter UI).
- `test/unit/data/`
  - Tests repository behavior and data mapping (often with fakes/mocks).
- `test/unit/presentation/` & `test/unit/services/`
  - Tests ViewModels/Notifiers and cross-cutting services.
- `test/widget/`
  - Tests UI widgets and pages (layout, wiring to providers, key interactions).
- `test/integration/`
  - End-to-end flows that exercise full features (auth, pets, care plans, sharing).

This mirrors the **testing levels** described in the Testing slides and supports safe, behavior-preserving refactoring.

---

## Guiding Principles

- **Behavior-Preserving Refactoring**
  - All structural and design improvements should be implemented using classic refactorings (Rename, Extract Method/Class, Replace Magic Number with Constant, Introduce Interface, etc.) without changing what the app does from a user’s perspective.

- **Separation of Concerns**
  - UI, application logic, domain logic, and data access are separated into clear modules and layers, as emphasized in the Software Design slides (`SWE/3. Software Design.md`).

- **Dependency Inversion & Testability**
  - Upper layers depend on abstractions (interfaces) defined in the domain layer.
  - Concrete implementations (e.g., Firestore) live in the data layer and are injected via providers, enabling easy unit testing.

- **Feature-First Organization**
  - Code relevant to a user-facing feature (auth, pets, care plans, sharing, etc.) is grouped together under that feature, making it easier to navigate and evolve each feature independently.


