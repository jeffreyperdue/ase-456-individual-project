🗓 Week 10 Plan – Petfolio (UI Polish & Error Handling)

Sprint 2 Theme: Final UX Polish & Stability Improvements
Duration: ~4.5 hours

🎯 Week 10 Objectives

Refine and polish the app’s user interface for a smoother experience.

Improve visual feedback, including success, error, and loading indicators.

Implement consistent button states, transitions, and micro-animations.

Enhance error handling with user-friendly messages and retry mechanisms.

Finalize Sprint 2 with a cohesive, professional, and stable build ready for testing.

🧱 Features & User Stories
Feature	Epic	User Stories	Status
Feature 5: Basic UI Improvements	User Experience Enhancement	US-012, US-013	🟡 Planned for Week 10
Feature 6: Error Handling Improvements	User Experience Enhancement	US-014, US-015	🟡 Planned for Week 10
US-012

As a user, I want better visual feedback when I complete actions so that I know my interactions are registered.

US-013

As a user, I want improved loading states so that the app feels more responsive.

US-014

As a user, I want clear error messages so that I know what went wrong and how to fix it.

US-015

As a user, I want helpful guidance when something fails so that I can resolve issues quickly.

Acceptance Criteria

- [ ] Basic success/error feedback animations
- [ ] Improved loading indicators
- [ ] Better button states and interactions
- [ ] Basic page transitions
- [ ] User-friendly error messages
- [ ] Basic retry mechanisms
- [ ] Clear guidance for common issues
- [ ] Better offline handling (basic network detection and messaging)

⚙️ Technical Implementation Plan
1. UI Polish & Visual Feedback

Standardize success and error snackbars using ScaffoldMessenger.
- Note: Some pages already have `_showSuccessSnackBar` and `_showErrorSnackBar` helpers (e.g., `care_plan_form_page.dart`, `pet_profile_form_page.dart`). Extract these into a shared utility or service for consistency.

Add simple success animations for positive user actions (e.g., "Task Completed!", "Pet saved successfully").
- Option: Use Lottie animations (requires adding `lottie` package to `pubspec.yaml`) OR use Flutter's built-in animations (AnimatedContainer, AnimatedIcon) for simplicity.

Introduce progress indicators with standardized colors and sizes.
- Standardize existing `CircularProgressIndicator` usage across the app.
- Create consistent loading state patterns for both `_isLoading` flags and Riverpod `AsyncValue` states.

Apply consistent button states (normal, loading, disabled).
- Many pages already use `_isLoading` flags with disabled buttons. Standardize this pattern.

Enhance page transitions using PageRouteBuilder with custom animations.
- Note: App currently uses basic `Navigator` (not go_router). Use `PageRouteBuilder` for custom transitions between screens.

2. Error Handling System

Implement a global error-handling service in `lib/services/error_handler.dart`:

```dart
class ErrorHandler {
  static void handleError(BuildContext context, Object error) {
    final message = _mapErrorToMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  static String _mapErrorToMessage(Object error) {
    if (error is FirebaseException) {
      // Map specific Firebase error codes to user-friendly messages
      if (error.code == 'permission-denied') {
        return "You don't have permission to perform this action.";
      } else if (error.code == 'unavailable') {
        return "Connection issue. Please check your internet and try again.";
      }
      return "Connection issue. Please try again.";
    }
    if (error is TimeoutException) return "The request took too long. Please try again.";
    return "Something went wrong. Please try again.";
  }
}
```

Integrate ErrorHandler throughout Firestore, Storage, and Auth interactions.
- Replace ad-hoc error handling in login_page.dart, signup_page.dart, edit_pet_page.dart, etc.
- Update existing error handling in lost_found, sharing, and care_plans features.

3. Loading & Retry Improvements

Standardize loading spinners during network operations.
- Many pages already use `CircularProgressIndicator`. Ensure consistent styling and placement.

Enhance retry mechanisms for failed operations.
- Note: Some retry buttons already exist (e.g., `home_page.dart` has a retry button for error states). Standardize this pattern.
- Add retry buttons for upload failures, Firestore write failures, etc.

Add basic offline detection and user-friendly messages.
- Note: Full offline support is deferred. For Week 10, add basic network connectivity checks and clear messages when operations fail due to network issues.

Add subtle fade-in/fade-out animations for content changes.
- Use `AnimatedSwitcher` or `FadeTransition` for smooth content updates.

4. Accessibility & Theming Consistency

Ensure color contrast meets accessibility standards.
- Review existing theme colors in `lib/app/theme.dart` for accessibility compliance.

Add semantic labels for buttons and icons.
- Add `Semantics` widgets or `Tooltip` widgets where appropriate for better accessibility.

Verify theme consistency across all major screens.
- Note: Dark mode support is deferred to future sprints. Focus on ensuring consistent light theme usage.
- Review and standardize padding, font weights, and margins using theme values.

🧪 Validation Path

Complete a full onboarding-to-dashboard run-through.

Test all core user actions:

Add/edit pet

Create care plan

Mark tasks complete

Share access

Mark pet as lost/found

Trigger success and error states manually to validate responses.

Test basic network error scenarios (simulate network failures, not full offline mode).

Review UI responsiveness on mobile, tablet, and web platforms.

🚧 Dependencies & Risks

Depends on: Completed Lost & Found flow (Week 9) and stable Firestore operations.

Risk: Overuse of animations impacting performance.

Mitigation: Use lightweight Flutter animations (AnimatedContainer, AnimatedIcon) or optimize Lottie files if used. Test on low-end devices. Consider deferring Lottie if time is limited.

Risk: Inconsistent error behavior across modules.

Mitigation: Centralize error handling in shared `ErrorHandler` service in `lib/services/`. Replace existing ad-hoc error handling patterns throughout the codebase.

Risk: Breaking existing functionality when standardizing patterns.

Mitigation: Test thoroughly after refactoring. Keep existing helper methods (`_showSuccessSnackBar`, `_showErrorSnackBar`) as fallback during transition period.

📊 Success Metrics
Metric	Target
App startup time	< 3 seconds
Animation smoothness	60 FPS average (if animations are added)
Error message clarity	All error messages are user-friendly and actionable
App crash rate	< 1% in testing
Visual consistency	100% theme alignment across screens
Error handling coverage	All major user flows have proper error handling

📝 Implementation Notes

**Current State:**
- Error handling is ad-hoc using `ScaffoldMessenger` with `SnackBar` throughout the codebase
- Some pages have helper methods (`_showSuccessSnackBar`, `_showErrorSnackBar`) that should be standardized
- Loading states use both `_isLoading` flags and Riverpod `AsyncValue` patterns
- Basic retry mechanisms exist in some places (e.g., `home_page.dart`)
- App uses basic `Navigator` (not go_router) for navigation
- No Lottie package currently in `pubspec.yaml` (add if using Lottie animations)

**Key Files to Update:**
- Create: `lib/services/error_handler.dart`
- Update: All pages with error handling (login_page.dart, signup_page.dart, edit_pet_page.dart, care_plan_form_page.dart, pet_profile_form_page.dart, etc.)
- Standardize: Loading indicators across all features
- Review: `lib/app/theme.dart` for consistency