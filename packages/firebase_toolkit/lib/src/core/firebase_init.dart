import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static bool _inited = false;

  static Future<void> init({FirebaseOptions? options}) async {
    if (_inited) return;
    await Firebase.initializeApp(options: options);
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };
    _inited = true;
  }
}
