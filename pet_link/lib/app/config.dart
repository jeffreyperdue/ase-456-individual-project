/// Global app-wide constants for routes, Firestore collections, and prefs keys.
///
/// Using symbolic constants instead of magic strings makes refactoring safer
/// and reduces the risk of typos, while keeping behavior identical.

/// Named routes used by the app.
class RouteNames {
  static const String root = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String welcome = '/welcome';
  static const String onboardingSuccess = '/onboarding-success';
  static const String sitterDashboard = '/sitter-dashboard';
  static const String editPet = '/edit';
  static const String petDetail = '/pet-detail';
  static const String sharePet = '/share-pet';
  static const String publicProfile = '/public-profile';
}

/// Firestore collection names used across features.
class FirestoreCollections {
  static const String pets = 'pets';
  static const String carePlans = 'care_plans';
  static const String petProfiles = 'pet_profiles';
  static const String accessTokens = 'access_tokens';
  static const String taskCompletions = 'task_completions';
  static const String lostReports = 'lost_reports';
  static const String users = 'users';
}

/// SharedPreferences keys for local storage.
class PrefsKeys {
  static const String onboardingComplete = 'onboarding_complete';
  static const String hasSeenWelcome = 'has_seen_welcome';
}


