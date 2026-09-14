import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'firestore_service.dart';
import '../../firebase_options.dart';

final notificationServiceProvider =
Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  StreamSubscription? _notificationSubscription;

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  // Request Notification Permission (Called strictly from PermissionScreen)
  Future<NotificationSettings> requestNotificationPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // ============================================================
  // INITIALIZE (Silent initialization without prompting permission)
  // ============================================================

  Future<void> init() async {
    try {
      final NotificationSettings settings = await _messaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Notification permission status: Authorized');
      } else {
        print('Notification permission status: ${settings.authorizationStatus}');
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

  // ============================================================
  // REAL-TIME FIRESTORE NOTIFICATIONS
  // ============================================================

  void startListeningToUserNotifications(String uid) {
    // Cancel existing subscription if any
    _notificationSubscription?.cancel();

    print('Starting Firestore notification listener for user: $uid');
    
    // Track processed IDs as a class-level or long-lived variable if possible
    // For now, we use the timestamp check which is more reliable across restarts
    final DateTime listenerStartTime = DateTime.now();
    
    _notificationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        // Handle both added and modified (for server timestamp updates)
        if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          
          // Only show popup for brand new notifications
          final timestamp = data['timestamp'] as Timestamp?;
          
          // If timestamp is null, it's a fresh addition (local). We'll wait for the server timestamp.
          // If it has a timestamp, we verify it's very recent (created after we started listening)
          if (timestamp != null && timestamp.toDate().isAfter(listenerStartTime.subtract(const Duration(seconds: 10)))) {
            _showLocalNotification(
              id: change.doc.id.hashCode,
              title: data['title'] ?? 'AnnaDaan',
              body: data['body'] ?? '',
            );
          }
        }
      }
    });
  }

  void stopListening() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
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
    // 1. Initialize Firebase for the background isolate
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Handling background message: ${message.messageId}');

    // 2. Extract location data from FCM data payload
    final data = message.data;
    if (data['latitude'] == null || data['longitude'] == null) return;

    final double postLat = double.parse(data['latitude'].toString());
    final double postLng = double.parse(data['longitude'].toString());

    // 3. Get device's current/last position
    // Note: Background location access might be needed for high accuracy, 
    // but getLastKnownPosition is a good low-battery fallback.
    Position? position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

    // 4. Calculate distance
    final distance = Geolocator.distanceBetween(
      postLat,
      postLng,
      position.latitude,
      position.longitude,
    );

    print('Background Distance Check: ${distance.toStringAsFixed(0)}m');

    // 5. Show notification if within 3km
    if (distance <= 3000) {
      final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      await localNotifications.show(
        id: message.hashCode,
        title: data['title'] ?? 'New Anadanam Nearby!',
        body: data['body'] ?? 'Check out new food serving near you.',
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    }
  } catch (e) {
    print('Background notification error: $e');
  }
}