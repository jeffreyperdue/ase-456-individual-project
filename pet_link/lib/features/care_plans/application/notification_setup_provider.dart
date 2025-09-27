import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'providers.dart';

/// State for notification setup and permissions.
class NotificationSetupState {
  final bool isInitialized;
  final bool hasPermissions;
  final bool isSetupComplete;
  final String? error;

  const NotificationSetupState({
    this.isInitialized = false,
    this.hasPermissions = false,
    this.isSetupComplete = false,
    this.error,
  });

  NotificationSetupState copyWith({
    bool? isInitialized,
    bool? hasPermissions,
    bool? isSetupComplete,
    String? error,
  }) {
    return NotificationSetupState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      error: error,
    );
  }
}

/// Notifier for managing notification setup and permissions.
class NotificationSetupNotifier extends StateNotifier<NotificationSetupState> {
  NotificationSetupNotifier(this._ref) : super(const NotificationSetupState());

  final Ref _ref;

  /// Initialize the notification system.
  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(error: null);

    try {
      final notifications = _ref.read(flutterLocalNotificationsProvider);

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await notifications.initialize(initSettings);

      if (initialized == true) {
        state = state.copyWith(isInitialized: true);

        // Check permissions after initialization
        await checkPermissions();
      } else {
        state = state.copyWith(error: 'Failed to initialize notifications');
      }
    } catch (e) {
      state = state.copyWith(error: 'Error initializing notifications: $e');
    }
  }

  /// Check current notification permissions.
  Future<void> checkPermissions() async {
    if (!state.isInitialized) return;

    try {
      final notifications = _ref.read(flutterLocalNotificationsProvider);

      // Check Android permissions
      final androidImpl =
          notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final androidPermissions =
          await androidImpl?.areNotificationsEnabled() ?? false;

      // For iOS, we'll assume permissions are granted if we can initialize
      // In a real app, you'd check the actual permission status
      final hasPermissions = androidPermissions;

      state = state.copyWith(
        hasPermissions: hasPermissions,
        isSetupComplete: state.isInitialized && hasPermissions,
      );

      // Update the global permissions provider
      _ref.read(notificationPermissionsProvider.notifier).state =
          hasPermissions;
    } catch (e) {
      state = state.copyWith(error: 'Error checking permissions: $e');
    }
  }

  /// Request notification permissions.
  Future<void> requestPermissions() async {
    if (!state.isInitialized) {
      await initialize();
    }

    try {
      final notifications = _ref.read(flutterLocalNotificationsProvider);

      // Request Android permissions
      final androidImpl =
          notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }

      // Request iOS permissions
      final iosImpl =
          notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      if (iosImpl != null) {
        await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
      }

      // Check permissions again after requesting
      await checkPermissions();
    } catch (e) {
      state = state.copyWith(error: 'Error requesting permissions: $e');
    }
  }

  /// Create notification channels (Android).
  Future<void> createNotificationChannels() async {
    if (!state.isInitialized) return;

    try {
      final notifications = _ref.read(flutterLocalNotificationsProvider);

      const feedingChannel = AndroidNotificationChannel(
        'care_plans_feeding',
        'Pet Feeding Reminders',
        description: 'Reminders for pet feeding times',
        importance: Importance.high,
      );

      const medicationChannel = AndroidNotificationChannel(
        'care_plans_medication',
        'Pet Medication Reminders',
        description: 'Reminders for pet medication times',
        importance: Importance.high,
      );

      final androidImpl =
          notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(feedingChannel);
        await androidImpl.createNotificationChannel(medicationChannel);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error creating notification channels: $e');
    }
  }

  /// Complete setup (initialize + create channels + check permissions).
  Future<void> completeSetup() async {
    await initialize();
    await createNotificationChannels();
    await checkPermissions();
  }

  /// Reset setup state.
  void reset() {
    state = const NotificationSetupState();
  }
}

/// Provider for notification setup state.
final notificationSetupProvider =
    StateNotifierProvider<NotificationSetupNotifier, NotificationSetupState>((
      ref,
    ) {
      return NotificationSetupNotifier(ref);
    });
