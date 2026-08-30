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
    apiKey: 'AIzaSyBmh44kvw6z_dxoKgf8NhX15v_xXl4eHRQ',
    appId: '1:938569948543:android:84f2a67048b46db33c8e4a',
    messagingSenderId: '938569948543',
    projectId: 'gothic-sequence-118012',
    storageBucket: 'gothic-sequence-118012.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmh44kvw6z_dxoKgf8NhX15v_xXl4eHRQ',
    appId: '1:938569948543:ios:baef02de22925dbec3bdda',
    messagingSenderId: '938569948543',
    projectId: 'gothic-sequence-118012',
    storageBucket: 'gothic-sequence-118012.firebasestorage.app',
    iosBundleId: 'com.vgsolutions.annadanam',
  );
}
