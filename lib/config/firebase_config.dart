import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  const FirebaseConfig._();

  static const String proyecto = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'demo-cinecatalogo',
  );

  static const String bucket = 'demo-cinecatalogo.appspot.com';

  static const bool usarEmulador = bool.fromEnvironment(
    'FIREBASE_EMULADOR',
    defaultValue: true,
  );

  static String get hostEmulador {
    const String definido = String.fromEnvironment('FIREBASE_EMULADOR_HOST');
    if (definido.isNotEmpty) return definido;
    return kIsWeb ? 'localhost' : '10.0.2.2';
  }

  static const int puertoFirestore = 8080;

  static const int puertoAuth = 9099;

  static FirebaseOptions get actuales => const FirebaseOptions(
        apiKey: 'demo-api-key-cinecatalogo',
        appId: '1:123456789012:android:6f1c2a9b8d4e7f01',
        messagingSenderId: '123456789012',
        projectId: proyecto,
        storageBucket: bucket,
      );
}
