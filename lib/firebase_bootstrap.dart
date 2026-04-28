import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

Future<void> initFirebase() async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    return;
  }

  // Prefer dart-define overrides (useful for CI or local runs),
  // otherwise fall back to `lib/firebase_options.dart`.
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  final hasDefines = apiKey.isNotEmpty && appId.isNotEmpty && messagingSenderId.isNotEmpty && projectId.isNotEmpty;

  final options = hasDefines
      ? FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          authDomain: authDomain.isEmpty ? null : authDomain,
          storageBucket: storageBucket.isEmpty ? null : storageBucket,
          measurementId: measurementId.isEmpty ? null : measurementId,
        )
      : DefaultFirebaseOptions.web;

  await Firebase.initializeApp(options: options);
}

