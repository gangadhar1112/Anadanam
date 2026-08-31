import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_service.dart';
import '../../firebase_options.dart';

final notificationServiceProvider =
Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> init() async {
    try {
      // ----------------------------------------------------------
      // Request notification permission
      // ----------------------------------------------------------

      final NotificationSettings settings =
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined notification permission');

        // Even if permission is denied, initialize
        // local notifications.
      }

      // ----------------------------------------------------------
      // Initialize local notifications
      // ----------------------------------------------------------

      const AndroidInitializationSettings
      initializationSettingsAndroid =
      AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
      );

      // IMPORTANT:
      // Your flutter_local_notifications version requires
      // the named "settings:" parameter.
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse:
        _onNotificationTap,
      );

      // ----------------------------------------------------------
      // Create Android notification channel
      // ----------------------------------------------------------

      const AndroidNotificationChannel channel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description:
        'This channel is used for important notifications.',
        importance: Importance.max,
      );

      final AndroidFlutterLocalNotificationsPlugin?
      androidPlugin =
      _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        channel,
      );

      // ----------------------------------------------------------
      // Get FCM token
      // ----------------------------------------------------------

      final String? token =
      await _getTokenWithRetry();

      if (token != null) {
        print('FCM Token: $token');
      }

      // ----------------------------------------------------------
      // Listen for token refresh
      // ----------------------------------------------------------

      _messaging.onTokenRefresh.listen(
            (String newToken) {
          print(
            'FCM Token refreshed: $newToken',
          );

          // We don't save here because we don't know
          // the current user inside NotificationService.
          //
          // AuthService will save the token when the
          // user signs in.
        },
      );

      // ----------------------------------------------------------
      // Foreground messages
      // ----------------------------------------------------------

      FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      // ----------------------------------------------------------
      // Subscribe to Global Topics
      // ----------------------------------------------------------

      try {
        await _messaging.subscribeToTopic('all_anadanam');
        print('Subscribed to all_anadanam topic');
      } catch (e) {
        print('Error subscribing to topic: $e');
      }

      print(
        'Notification service initialized successfully',
      );
    } catch (e, stackTrace) {
      print(
        'Notification service initialization error: $e',
      );

      print(stackTrace);
    }
  }

  // ============================================================
  // FOREGROUND MESSAGE
  // ============================================================

  Future<void> _handleForegroundMessage(
      RemoteMessage message,
      ) async {
    try {
      print(
        'Foreground message received: '
            '${message.messageId}',
      );

      final RemoteNotification? notification =
          message.notification;

      if (notification == null) {
        return;
      }

      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'AnnaDaan',
        body: notification.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
            'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      print(
        'Foreground notification error: $e',
      );
    }
  }

  // ============================================================
  // NOTIFICATION TAP
  // ============================================================

  void _onNotificationTap(
      NotificationResponse response,
      ) {
    print(
      'Notification tapped: ${response.payload}',
    );

    // Navigation can be added here later.
  }

  // ============================================================
  // UPDATE FCM TOKEN
  // ============================================================

  Future<void> updateToken(
      String uid,
      String token,
      ) async {
    try {
      await _ref
          .read(firestoreServiceProvider)
          .saveFcmToken(
        uid,
        token,
      );

      print(
        'FCM token saved for user: $uid',
      );
    } catch (e) {
      print(
        'Error updating FCM token: $e',
      );
    }
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails
      androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription:
        'Used for testing notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails
      platformChannelSpecifics =
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        id: 0,
        title: 'AnnaDaan Test',
        body: 'This is a test notification from the AnnaDaan app!',
        notificationDetails: platformChannelSpecifics,
      );
    } catch (e) {
      print(
        'Test notification error: $e',
      );
    }
  }

  // ============================================================
  // GET FCM TOKEN WITH RETRY
  // ============================================================

  Future<String?> _getTokenWithRetry({
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final String? token =
        await _messaging.getToken();

        if (token != null) {
          return token;
        }

        attempts++;

        print(
          'FCM token is null. Attempt: $attempts',
        );
      } on FirebaseException catch (e) {
        attempts++;

        print(
          'FCM Token attempt $attempts failed: '
              '${e.code} - ${e.message}',
        );

        if (e.code == 'unknown' ||
            e.message
                ?.contains('Firebase Installations') ==
                true) {
          print(
            'Firebase Installations error detected.',
          );

          print(
            'Check Firebase configuration and API key.',
          );
        }

        if (attempts >= maxRetries) {
          break;
        }

        await Future.delayed(
          Duration(seconds: 2 * attempts),
        );
      } catch (e) {
        attempts++;

        print(
          'FCM Token attempt $attempts failed: $e',
        );

        if (attempts >= maxRetries) {
          break;
        }

        await Future.delayed(
          Duration(seconds: 2 * attempts),
        );
      }
    }

    return null;
  }
}

// ================================================================
// FCM BACKGROUND HANDLER
// ================================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  try {
    // Background messages run in a separate isolate.
    // Firebase must be initialized in that isolate.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (!e.toString().contains('duplicate-app')) {
        rethrow;
      }
    }

    print(
      'Handling background message: '
          '${message.messageId}',
    );
  } catch (e) {
    print(
      'Background notification error: $e',
    );
  }
}