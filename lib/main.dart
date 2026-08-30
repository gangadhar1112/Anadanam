import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase should be initialized exactly once.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Register background FCM handler.
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  final container = ProviderContainer();

  await container
      .read(notificationServiceProvider)
      .init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AnnaDaanApp(),
    ),
  );
}

class AnnaDaanApp extends StatelessWidget {
  const AnnaDaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnnaDaan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}