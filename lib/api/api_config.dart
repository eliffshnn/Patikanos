import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Backend adresi. Tek yerden değişsin diye burada.
class ApiConfig {
  // Gerçek telefonda denemek için:
  // flutter run --dart-define=API_BASE_URL=http://<bilgisayarın-IP'si>:8000
  static const _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    // Android emülatörü bilgisayara 10.0.2.2 üzerinden ulaşır
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
    // iOS simülatörü, macOS, web
    return 'http://127.0.0.1:8000';
  }
}