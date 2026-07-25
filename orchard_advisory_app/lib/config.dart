import 'package:flutter/foundation.dart';

class AppConfig {
  /// Override at run/build time:
  /// `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000`
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Browser / desktop → host machine. Android emulator → special loopback alias.
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return 'http://10.0.2.2:8000';
  }
}
