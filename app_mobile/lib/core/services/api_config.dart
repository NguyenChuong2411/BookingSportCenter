import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get _host {
    if (kIsWeb) {
      return 'http://127.0.0.1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2';
    }

    return 'http://localhost';
  }

  static String get bookingBaseUrl => '$_host:5253/api';
  static String get authBaseUrl => '$_host:5236/api';
}
