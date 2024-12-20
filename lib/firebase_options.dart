// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIGxs1wOqWWgh5ZBMyAEl5k8ACODy1P5E',
    appId: '1:918448528675:web:d6f9442d75bdfca0070096',
    messagingSenderId: '918448528675',
    projectId: 'stoc-one',
    authDomain: 'stoc-one.firebaseapp.com',
    storageBucket: 'stoc-one.firebasestorage.app',
    measurementId: 'G-NJ06YZHWDR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrqNIhF6pDpB8mv9VEH4Knuhiju3A6YNM',
    appId: '1:918448528675:android:9880b3bfdb545157070096',
    messagingSenderId: '918448528675',
    projectId: 'stoc-one',
    storageBucket: 'stoc-one.firebasestorage.app',
  );
}
