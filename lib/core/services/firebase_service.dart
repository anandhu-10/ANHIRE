import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _fallbackMode = false;

  static bool get isFirebaseAvailable => _initialized && !_fallbackMode;

  /// Initializes Firebase and handles potential missing services files gracefully.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // In web/desktop or if configuration files are missing, this might throw
      await Firebase.initializeApp();
      _initialized = true;
      _fallbackMode = false;
      debugPrint("Firebase successfully initialized.");
    } catch (e) {
      _initialized = true;
      _fallbackMode = true;
      debugPrint("-----------------------------------------------------------------");
      debugPrint("WARNING: Firebase could not be initialized.");
      debugPrint("Reason: $e");
      debugPrint("ANHIRE will run in simulated OFFLINE/FALLBACK demonstration mode.");
      debugPrint("To connect real services, please add your Google Services files.");
      debugPrint("-----------------------------------------------------------------");
    }
  }
}
