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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA3-hi0ZmQJzvu2MQ72GJ1z-vt1G70ihpE',
    appId: '1:432578366043:web:f4b9d23c9b603779f3cd7e',
    messagingSenderId: '432578366043',
    projectId: 'anhire-ff6e2',
    authDomain: 'anhire-ff6e2.firebaseapp.com',
    storageBucket: 'anhire-ff6e2.firebasestorage.app',
    measurementId: 'G-EY92LQ8KVT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3-hi0ZmQJzvu2MQ72GJ1z-vt1G70ihpE',
    appId: '1:432578366043:android:f4b9d23c9b603779f3cd7e',
    messagingSenderId: '432578366043',
    projectId: 'anhire-ff6e2',
    storageBucket: 'anhire-ff6e2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3-hi0ZmQJzvu2MQ72GJ1z-vt1G70ihpE',
    appId: '1:432578366043:ios:f4b9d23c9b603779f3cd7e',
    messagingSenderId: '432578366043',
    projectId: 'anhire-ff6e2',
    storageBucket: 'anhire-ff6e2.firebasestorage.app',
    iosBundleId: 'com.example.anhire',
  );
}
