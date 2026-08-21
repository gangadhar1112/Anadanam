import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2xt-AHbVtjeDAlNb5nsCjMgL5TK3w9NM',
    appId: '1:416339301679:android:9bdc4c3188bb8b97c3bdda',
    messagingSenderId: '416339301679',
    projectId: 'annadaan-app-2026-v1',
    storageBucket: 'annadaan-app-2026-v1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCO8QTN1XKWVFqY4clRJh-711gtfKUmglw',
    appId: '1:416339301679:ios:baef02de22925dbec3bdda',
    messagingSenderId: '416339301679',
    projectId: 'annadaan-app-2026-v1',
    storageBucket: 'annadaan-app-2026-v1.firebasestorage.app',
    iosBundleId: 'com.example.anadanaapp',
  );
}
