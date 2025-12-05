// This file will hold the FirebaseOptions for all platforms.
// Values are loaded from .env file for security.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
    );
  }
}
