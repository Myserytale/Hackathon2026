import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get origin {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return 'http://localhost:8080';
  }

  static String get authBaseUrl => '$origin/api/auth';
  static String get apiBaseUrl => '$origin/api';
}
