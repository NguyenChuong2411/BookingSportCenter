import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _definedHost = String.fromEnvironment('API_HOST');

  static String get _host {
    if (_definedHost.isNotEmpty) {
      return _definedHost;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Works for Android emulator. For a real device, pass --dart-define=API_HOST=http://<your-lan-ip>
      return 'http://10.0.2.2';
    }

    return 'http://localhost';
  }

  static String get bookingBaseUrl => '$_host:5253/api';
  static String get authBaseUrl => '$_host:5236/api';
}
