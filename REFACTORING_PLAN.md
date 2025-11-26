## Petfolio Refactoring Plan (Behavior‑Preserving)

This document describes a **behavior‑preserving** refactoring plan for the Petfolio app.  
The goal is to improve architecture, readability, and testability using the course materials in `pet_link/ref_docs` (Software Architecture, Software Design, MVVM, SOLID, Refactoring, and Testing) **without changing any existing features or user‑visible behavior**.

All steps should be implemented using standard, safe refactorings (Rename, Move/Extract Method or Class, Replace Magic Number with Constant, Introduce Interface, etc.).

---

## 1. Global Architecture & Modules

**Goal**: Make the high‑level architecture explicit and consistent across all features, with no runtime behavior changes.

### 1.1 Normalize Folder & Layer Structure

- **Keep** current high‑level layout:
  - `pet_link/lib/app` – app shell, routing, theming, scaffolding
  - `pet_link/lib/features` – feature modules (auth, pets, care_plans, sharing, lost_found, onboarding)
  - `pet_link/lib/services` – cross‑cutting infrastructure (local storage, error handling, network)
  - `pet_link/test` – unit, widget, and integration tests
- **Standardize each feature** into the same layered structure:
  - `domain/` – entities, value objects, repository interfaces, domain services
  - `data/` – repository implementations, Firestore/remote adapters, DTOs
  - `application/` – use cases, ViewModels/StateNotifiers, feature‑level providers
  - `presentation/` – widgets and pages only (no direct Firestore or business logic)
- **Operations**: Move files between these folders and fix imports only. Do not change method logic.

### 1.2 Architecture Overview Doc

- Add a short `ARCHITECTURE.md` under `pet_link/` that:
  - Explains the roles of **app**, **features**, **domain/data/application/presentation** using terminology from:
    - `ref_docs/course_docs/SWE/2. Software Architecture.md`
    - `ref_docs/course_docs/SWE/3. Software Design.md`
    - `ref_docs/course_docs/3. MVVM/1. MVVM Pattern in Flutter.pdf`
  - Describes how Riverpod providers are used as the composition root.
- This is documentation only (no code behavior change).

---

## 2. Presentation Layer → Consistent MVVM

**Goal**: Make every screen follow a consistent Model–View–ViewModel split. Views are dumb; ViewModels hold UI logic and state.

### 2.1 Introduce ViewModels for Complex Screens

Target features (order can be adjusted):

- `features/auth`: login, signup, profile
- `features/pets`: pet list, detail, edit/add flows
- `features/care_plans`: dashboard, form, view, today‑tasks
- `features/sharing`: `SharePetPage`, sitter dashboard, public profile

For each screen:

- Introduce or rename an existing `StateNotifier` into a clear ViewModel, e.g.:
  - `LoginViewModel`, `SignupViewModel`, `ProfileViewModel`
  - `PetListViewModel`, `PetDetailViewModel`, `PetFormViewModel`
  - `CarePlanFormViewModel`, `CareDashboardViewModel`
  - `SharePetViewModel`, `SitterDashboardViewModel`
- Move existing imperative UI logic into the ViewModel, for example:
  - Sharing logic in `SharePetPage` (`_createHandoff`, managing `_isCreating`, etc.).
  - Form submission, validation, and saving flows currently inside widgets.
  - Any direct repository or service calls in pages.
- Widgets become thin “Views” that:
  - Read `AsyncValue` state from the ViewModel via Riverpod.
  - Call ViewModel methods for actions (`submitForm()`, `sharePet()`, `completeTask()`, etc.).

Use **Extract Method** and **Move Method** refactorings to move logic gradually, keeping signatures and behavior the same.

### 2.2 Standardize How Views Consume State

For all `presentation/pages`:

- Ensure pages:
  - Do **not** talk directly to Firestore repositories or low‑level services.
  - Only read data through providers / ViewModels.
  - Trigger actions via ViewModel methods.
- Gradually replace direct imports of `*RepositoryImpl` and services in UI with ViewModel usage.

This aligns with the MVVM and Software Architecture slides, improving separation of concerns and testability without changing observable behavior.

### 2.3 Simplify `AppStartup` with a ViewModel

- Introduce an `AppStartupViewModel` (in `app/` or `features/auth`/`features/pets` as appropriate) that computes a small startup state enum, e.g.:
  - `StartupState.loading`
  - `StartupState.needsWelcome`
  - `StartupState.needsPetSetup`
  - `StartupState.showMain`
- Move logic that currently lives in `AppStartup.build` and nested `when` calls into this ViewModel:
  - Reading `authProvider`, onboarding flags, pets list.
  - Deciding when to mark onboarding as complete for existing users.
- Keep routing behavior the same:
  - `AppStartup` widget simply switches on the ViewModel state and returns the same screens it does now.

---

## 3. Domain & Data Layers (Repositories, Value Objects)

**Goal**: Keep domain models pure and expressive, repositories uniform, and dependencies injectable, while preserving all behavior.

### 3.1 Clean Up Domain Entities

Domain examples: `CarePlan`, `FeedingSchedule`, `Medication`, `PetProfile`, `Pet`, `AccessToken`, etc.

- Keep domain classes:
  - Free of UI concerns (no `BuildContext`, widgets, or SnackBars).
  - Free of infrastructure (no Firestore calls, no `SharedPreferences`).
- Extract heavy validation logic from entities into dedicated validator classes, e.g.:
  - `CarePlanValidator.validate(CarePlan carePlan) → List<String>`
  - `MedicationValidator.validate(Medication medication)`
- Introduce small **value objects** instead of primitive encodings where appropriate:
  - Wrap HH:mm strings as `ScheduledTime` (encapsulates format validation currently in `_isValidTimeFormat`).
  - Wrap day‑of‑week integers as `DayOfWeek` (enforces 0–6 range, possibly with named constructors for days).
- Steps (behavior‑preserving):
  - Initially, have entity methods call into the new validator/value objects.
  - Gradually migrate call sites to use validators directly and simplify entities.

### 3.2 Normalize Repository Pattern Across Features

For each feature:

- Ensure a **repository interface** exists in `domain/` (e.g., `CarePlanRepository`, `PetProfileRepository`, `AccessTokenRepository`, `TaskCompletionRepository`, `PetsRepository` if not already there).
- Ensure a **repository implementation** exists in `data/` (e.g., `CarePlanRepositoryImpl`, `PetProfileRepositoryImpl`, etc.) that:
  - Implements the domain interface.
  - Encapsulates all Firestore access, using consistent naming and collection paths.

Introduce a small abstract `FirestoreRepository<T>` base class or mixin (Template Method pattern) that handles common patterns:

- `collectionName` getter.
- Helper methods like `watchByField`, `getById`, `create`, `update`, `delete`.
- Shared conversions from `DocumentSnapshot` to entities via `fromJson`.

Refactor concrete repositories (`CarePlanRepositoryImpl`, `PetProfileRepositoryImpl`, pets repo, sharing repos) to extend/compose this base class, removing duplicated Firestore boilerplate without altering queries or data shape.

### 3.3 Apply Dependency Injection Consistently

- Replace internal use of singletons like `FirebaseFirestore.instance` and `SharedPreferences.getInstance()` with constructor parameters:
  - Repositories receive a `FirebaseFirestore` instance.
  - `LocalStorageService` receives a `SharedPreferences` instance or a factory.
- Wire these dependencies via Riverpod providers:
  - Providers remain the composition root and continue to provide default instances (so behavior is unchanged in production).
  - Tests can override providers with fakes/mocks.

This follows the Dependency Inversion Principle from the SOLID slides and improves testability without changing runtime behavior.

---

## 4. Cross‑Cutting Concerns: Errors, Networking, Configuration

**Goal**: Centralize and standardize error handling, connectivity, and constants while preserving existing UI messages and flows.

### 4.1 Modularize Error Handling

Current state:

- `ErrorHandler` already maps low‑level errors (FirebaseAuthException, FirebaseException, timeouts, generic network errors) to friendly messages, matching the Week 10 manual testing guide.

Refactoring steps:

- Extract the mapping logic into small, focused mappers, e.g.:
  - `AuthErrorMapper`
  - `FirestoreErrorMapper`
  - `NetworkErrorMapper`
  - `DefaultErrorMapper`
- Have each mapper implement a simple interface (e.g., `String? map(Object error)`).
- Implement a top‑level orchestrator in `ErrorHandler` that iterates over mappers (Chain of Responsibility pattern) and returns the first non‑null message.
- Keep all messages and mapping conditions identical to the current implementation.

### 4.2 Introduce a Result/Either Type in Application Layer

For use cases in `application/` (e.g., `save_care_plan_use_case`, `schedule_reminders_use_case`, `create_access_token_use_case`, authentication use cases):

- Introduce a simple `Result<Success, Failure>` or `Either<Failure, Success>` type (sealed class or union).
- Wrap existing logic so that:
  - Use cases catch exceptions internally.
  - Map them to a `Failure` type (possibly with error codes).
  - Return `Result.failure` instead of throwing.
- ViewModels interpret the `Result` and:
  - Map `Failure` to user messages via `ErrorHandler`.
  - Update `AsyncValue` state accordingly.

Do this incrementally per use case; external behavior (what the user sees) remains the same.

### 4.3 Replace Magic Strings with Constants/Enums

Create modules for shared configuration:

- `FirestoreCollections` / `FirestoreFields`
- `PrefsKeys` (SharedPreferences keys)
- `RouteNames` (Flutter route strings)

Refactor:

- Replace inline strings like `'care_plans'`, `'pet_profiles'`, `'onboarding_complete'`, `'has_seen_welcome'`, `'/login'` with references to these constants.
- Ensure all references are updated to avoid typos and ensure consistency.

This directly applies “Replace Magic Number (or String) with Symbolic Constant” from the refactoring slides, without affecting behavior.

### 4.4 Unify Connectivity Behavior

- Wrap `NetworkService.hasConnection()` and `ErrorHandler.isNetworkError` under a single `ConnectivityService` or similar abstraction.
- Use this abstraction in use cases and ViewModels to:
  - Early‑return with a standardized “No internet connection…” failure when offline.
  - Keep existing user‑facing messages identical to those specified in:
    - `week10_manual_testing_guide.md`.
- Start by delegating existing calls through the new service so that behavior is unchanged.

---

## 5. Testing Alignment with Architecture

**Goal**: Maintain and improve test coverage so refactorings remain safe, and the system still meets all requirements.

### 5.1 Protect Current Behavior with Tests

Before larger refactoring steps, add or verify tests for:

- **Domain entities**:
  - `CarePlan` summary and validation rules.
  - Equality and hashCode for key entities.
- **Critical flows**:
  - Authentication (sign up, login, logout, invalid credentials).
  - Pet CRUD (create/edit/delete, list updates).
  - Care plan creation/update/deletion and schedule generation.
  - Sharing flows (creating tokens, revoking, viewing shared profiles).
- **Error handling**:
  - Given specific exceptions (`FirebaseAuthException` codes, Firestore permission errors, timeouts), verify friendly messages match the current expectations and the manual testing guide.

These tests serve as a safety net to ensure behavior remains unchanged.

### 5.2 Shift Logic Testing to ViewModels

After introducing ViewModels:

- Add unit tests for ViewModels (not just widgets) to cover:
  - State transitions (idle → loading → success/error).
  - Edge cases (no pets, missing care plans, invalid input, network errors).
  - Correct mapping of `Result`/`Failure` to user‑visible states.
- Keep existing widget tests focused on layout and interaction wiring.

This leverages the MVVM pattern’s testability advantages described in the course slides.

---

## 6. Suggested Execution Order

To minimize risk and keep functionality stable, apply refactorings in phases:

1. **Phase 0 – Safety Net**
   - Ensure all current tests pass (unit, widget, integration).
   - Optionally add a small number of smoke tests for main flows (auth, pet CRUD, care plans, sharing).

2. **Phase 1 – Structural, No Logic Changes**
   - Normalize feature folder structure (domain/data/application/presentation).
   - Introduce constants modules (`FirestoreCollections`, `PrefsKeys`, `RouteNames`) and update imports.
   - Introduce DI-friendly constructors for repositories and services, wiring them via providers.

3. **Phase 2 – MVVM Per Feature**
   - For each feature (auth, pets, care_plans, sharing), introduce ViewModels and move widget logic into them.
   - Run tests and fix any wiring issues while preserving behavior.

4. **Phase 3 – Domain & Repositories**
   - Introduce value objects and validators for complex domain types (e.g., schedule times, days of week).
   - Add a base Firestore repository abstraction and refactor existing repos to use it.

5. **Phase 4 – Cross‑Cutting Concerns**
   - Modularize `ErrorHandler` using small mappers (Chain of Responsibility style).
   - Introduce `Result`/`Failure` types in use cases and integrate with ViewModels.
   - Unify connectivity behavior under a `ConnectivityService`.

At each phase, rely on the refactoring patterns and design principles from the provided slides to guide small, reversible steps that keep the app’s behavior unchanged.


