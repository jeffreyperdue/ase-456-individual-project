// Test configuration for PetLink testing suite
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

/// Test configuration utilities and setup
class TestConfig {
  static bool _firebaseInitialized = false;

  /// Initialize test environment
  static void initialize() {
    // Set up method channels for testing
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock platform channels if needed
    _setupPlatformChannels();

    // Initialize Firebase for testing
    _initializeFirebase();

    // Set up any global test configurations
    _setupGlobalConfig();
  }

  /// Initialize Firebase for testing
  static void _initializeFirebase() {
    if (_firebaseInitialized) return;

    try {
      // Set up Firebase Core channel mocks
      // Note: Firebase Core initialization in tests requires complex setup
      // For now, we mock the channels to prevent errors
      _firebaseInitialized = true;
    } catch (e) {
      // If Firebase initialization setup fails, continue with mocks
      _firebaseInitialized = true;
    }
  }

  /// Set up platform channels for testing
  static void _setupPlatformChannels() {
    // Mock image picker channel
    const MethodChannel(
      'plugins.flutter.io/image_picker',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'pickImage':
          return 'mock_image_path';
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message:
                'Image picker mock not implemented for ${methodCall.method}',
          );
      }
    });

    // Mock local notifications channel
    const MethodChannel(
      'dexterous.com/flutter/local_notifications',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
          return true;
        case 'requestPermissions':
          return true;
        case 'show':
          return true;
        case 'cancel':
          return true;
        case 'cancelAll':
          return true;
        default:
          return null;
      }
    });

    // Mock share plus channel
    const MethodChannel(
      'dev.fluttercommunity.plus/share',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'share':
          return null;
        default:
          return null;
      }
    });

    // Mock URL launcher channel
    const MethodChannel(
      'plugins.flutter.io/url_launcher',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'canLaunch':
          return true;
        case 'launch':
          return true;
        default:
          return null;
      }
    });

    // Mock SharedPreferences channel
    const MethodChannel(
      'plugins.flutter.io/shared_preferences',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getAll':
          return <String, dynamic>{};
        case 'setBool':
        case 'setInt':
        case 'setDouble':
        case 'setString':
        case 'setStringList':
          return true;
        case 'remove':
        case 'clear':
          return true;
        default:
          return null;
      }
    });

    // Mock Firebase Core channel first
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_core'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Firebase#initializeCore') {
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'mock-api-key',
                'appId': 'mock-app-id',
                'messagingSenderId': 'mock-sender-id',
                'projectId': 'mock-project-id',
              },
              'pluginConstants': {},
            }
          ];
        }
        if (methodCall.method == 'Firebase#initializeApp') {
          return {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'mock-api-key',
              'appId': 'mock-app-id',
              'messagingSenderId': 'mock-sender-id',
              'projectId': 'mock-project-id',
            },
            'pluginConstants': {},
          };
        }
        if (methodCall.method == 'Firebase#app') {
          return {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'mock-api-key',
              'appId': 'mock-app-id',
              'messagingSenderId': 'mock-sender-id',
              'projectId': 'mock-project-id',
            },
            'pluginConstants': {},
          };
        }
        return null;
      },
    );

    // Mock Firebase Auth channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_auth'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'Auth#registerIdTokenListener':
          case 'Auth#registerAuthStateListener':
            return {'user': null};
          case 'Auth#signInWithEmailAndPassword':
            return {
              'user': {
                'uid': 'mock_user_id',
                'email': 'test@example.com',
                'displayName': 'Test User',
              },
            };
          case 'Auth#createUserWithEmailAndPassword':
            return {
              'user': {
                'uid': 'mock_user_id',
                'email': 'test@example.com',
                'displayName': 'Test User',
              },
            };
          case 'Auth#signOut':
            return null;
          case 'Auth#sendPasswordResetEmail':
            return null;
          case 'Auth#getCurrentUser':
            return {'user': null};
          default:
            return null;
        }
      },
    );

    // Mock Firestore channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/cloud_firestore'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'Query#snapshots':
            return <String, dynamic>{};
          case 'DocumentReference#snapshots':
            return <String, dynamic>{};
          case 'Query#get':
            return {
              'documents': <Map<String, dynamic>>[],
            };
          case 'DocumentReference#get':
            return {
              'exists': false,
              'data': <String, dynamic>{},
            };
          case 'DocumentReference#set':
            return null;
          case 'DocumentReference#update':
            return null;
          case 'DocumentReference#delete':
            return null;
          default:
            return null;
        }
      },
    );

    // Mock Firebase Storage channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_storage'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'Reference#putFile':
          case 'Reference#putData':
            return {
              'bucket': 'mock-bucket',
              'fullPath': 'mock/path.jpg',
              'name': 'mock-file.jpg',
              'metadata': <String, dynamic>{},
            };
          case 'Reference#getDownloadURL':
            return 'https://mock-storage-url.com/file.jpg';
          default:
            return null;
        }
      },
    );
  }

  /// Set up global test configuration
  static void _setupGlobalConfig() {
    // Configure test environment
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up any additional global configurations here
  }

  /// Clean up after tests
  static void cleanup() {
    // Clean up any resources if needed
    const MethodChannel(
      'plugins.flutter.io/image_picker',
    ).setMockMethodCallHandler(null);

    const MethodChannel(
      'dexterous.com/flutter/local_notifications',
    ).setMockMethodCallHandler(null);

    const MethodChannel(
      'dev.fluttercommunity.plus/share',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/url_launcher',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/firebase_auth',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/cloud_firestore',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'plugins.flutter.io/firebase_storage',
    ).setMockMethodCallHandler(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_core'),
      null,
    );
    const MethodChannel(
      'plugins.flutter.io/shared_preferences',
    ).setMockMethodCallHandler(null);
  }
}

/// Test environment setup for all tests
void setupTestEnvironment() {
  TestConfig.initialize();
}

/// Test environment cleanup for all tests
void cleanupTestEnvironment() {
  TestConfig.cleanup();
}
