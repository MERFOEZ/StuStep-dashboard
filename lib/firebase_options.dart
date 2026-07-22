import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// ──────────────────────────────────────────────────────────────────────────────
/// PLACEHOLDER — Replace with your real Firebase project configuration.
/// Run `flutterfire configure` to auto-generate this file, or manually paste
/// the values from the Firebase Console → Project Settings → Web App.
/// ──────────────────────────────────────────────────────────────────────────────
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-dCwcS4V2cRToHeRwxF8VyOj2Kf7SOpo',
    appId: '1:165136018294:web:8ac381ea15356143fc6857',
    messagingSenderId: '165136018294',
    projectId: 'stustep-4c1ea',
    authDomain: 'stustep-4c1ea.firebaseapp.com',
    storageBucket: 'stustep-4c1ea.firebasestorage.app',
  );
}
