import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is configured via `flutterfire configure`. The forgot-password
  // screen uses it to send real password-reset emails; the rest of the app
  // (marketplace, services, profiles) works entirely with local/mock data.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase ever fails to initialise, continue without it so the app
    // still launches.
    debugPrint('Firebase initialisation skipped: $e');
  }

  runApp(const WorklanceApp());
}
