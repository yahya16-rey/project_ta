import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAQTP3TyLYXCWybZUzwz4OmydQeC5RNbrs',
    appId: '1:825392939910:web:75c56ccbd134495e2c6207',
    messagingSenderId: '825392939910',
    projectId: 'project-ta-c6051',
    authDomain: 'project-ta-c6051.firebaseapp.com',
    storageBucket: 'project-ta-c6051.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyAndroidPlaceholder123',
    appId: '1:1234567890:android:dummyappid',
    messagingSenderId: '1234567890',
    projectId: 'jamu-herbal-mock-project',
    storageBucket: 'jamu-herbal-mock-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyIosPlaceholder12345',
    appId: '1:1234567890:ios:dummyappid',
    messagingSenderId: '1234567890',
    projectId: 'jamu-herbal-mock-project',
    storageBucket: 'jamu-herbal-mock-project.appspot.com',
    iosBundleId: 'com.example.project_ta',
  );
}
