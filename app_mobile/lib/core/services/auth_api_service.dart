import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthApiService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = {'email': email, 'password': password};

      final response = await http
          .post(
            Uri.parse('${ApiConfig.authBaseUrl}/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(data['message'] ?? 'Login failed');
    } catch (e) {
      debugPrint('Error logging in: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final request = {
        'username': username,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.authBaseUrl}/auth/register'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(data['message'] ?? 'Register failed');
    } catch (e) {
      debugPrint('Error registering: $e');
      rethrow;
    }
  }
}
