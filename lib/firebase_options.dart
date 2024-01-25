// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyATP58y8_zA_QYRABE6sijXauxEuLXexcg',
    appId: '1:30093748070:web:93b3f495cc6fbf38210aa7',
    messagingSenderId: '30093748070',
    projectId: 'awign-chat',
    authDomain: 'awign-chat.firebaseapp.com',
    databaseURL: 'https://awign-chat.firebaseio.com',
    storageBucket: 'awign-chat.appspot.com',
    measurementId: 'G-JDHK7T7H1W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDt2MSVfLT72G9CIOFUFwMVuosKDZL42Ms',
    appId: '1:30093748070:android:2edceffc36c47033',
    messagingSenderId: '30093748070',
    projectId: 'awign-chat',
    databaseURL: 'https://awign-chat.firebaseio.com',
    storageBucket: 'awign-chat.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApwzJ3YNRak3lBXmJSz9DVg2g4S7eMqzo',
    appId: '1:30093748070:ios:8ea389052734c6c7210aa7',
    messagingSenderId: '30093748070',
    projectId: 'awign-chat',
    databaseURL: 'https://awign-chat.firebaseio.com',
    storageBucket: 'awign-chat.appspot.com',
    androidClientId: '30093748070-3lepf2q3ja35eos9c2caa875ai7mhgja.apps.googleusercontent.com',
    iosClientId: '30093748070-0g4j9vm9ctsg4stvgnanafcrlnqr8bt1.apps.googleusercontent.com',
    iosBundleId: 'com.awign.intern',
  );
}