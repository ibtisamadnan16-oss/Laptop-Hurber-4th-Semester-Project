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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyB1-4FK9BYNoWkYWaaoxKNep9QIRJdSDeU',
    appId: '1:291158109284:web:29e165e06c200828ad4371',
    messagingSenderId: '291158109284',
    projectId: 'laptopharbour-4098f',
    authDomain: 'laptopharbour-4098f.firebaseapp.com',
    storageBucket: 'laptopharbour-4098f.firebasestorage.app',
    measurementId: 'G-EYR8XW66N9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDK-ubApRparQpNTjig4-twud65zGxEoUE',
    appId: '1:291158109284:android:03901ad058d79a8fad4371',
    messagingSenderId: '291158109284',
    projectId: 'laptopharbour-4098f',
    storageBucket: 'laptopharbour-4098f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2g4j6gUei58qcLpSfkRW9lKQATZloXDc',
    appId: '1:291158109284:ios:fe6e7a752f6c49b8ad4371',
    messagingSenderId: '291158109284',
    projectId: 'laptopharbour-4098f',
    storageBucket: 'laptopharbour-4098f.firebasestorage.app',
    iosBundleId: 'com.example.eProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2g4j6gUei58qcLpSfkRW9lKQATZloXDc',
    appId: '1:291158109284:ios:fe6e7a752f6c49b8ad4371',
    messagingSenderId: '291158109284',
    projectId: 'laptopharbour-4098f',
    storageBucket: 'laptopharbour-4098f.firebasestorage.app',
    iosBundleId: 'com.example.eProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB1-4FK9BYNoWkYWaaoxKNep9QIRJdSDeU',
    appId: '1:291158109284:web:0d3dfb6ea01de00fad4371',
    messagingSenderId: '291158109284',
    projectId: 'laptopharbour-4098f',
    authDomain: 'laptopharbour-4098f.firebaseapp.com',
    storageBucket: 'laptopharbour-4098f.firebasestorage.app',
    measurementId: 'G-R6FV3L003T',
  );
}
