import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'This admin dashboard is only supported on the web platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDrWrVmpE2odhHON3TC9CovgewzpF3nXys',
    appId: '1:611121520187:web:29098cb4172942f633c61e',
    messagingSenderId: '611121520187',
    projectId: 'stustep-app-99',
    authDomain: 'stustep-app-99.firebaseapp.com',
    storageBucket: 'stustep-app-99.firebasestorage.app',
  );
}
