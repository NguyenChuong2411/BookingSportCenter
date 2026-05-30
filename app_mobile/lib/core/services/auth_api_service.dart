import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthApiService {
  static String? _jwtToken;
  static const Duration _requestTimeout = Duration(seconds: 30);

  static void setJwtToken(String token) {
    _jwtToken = token;
  }

  static String? getJwtToken() => _jwtToken;

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = {'email': email, 'password': password};
      final url = '${ApiConfig.authBaseUrl}/auth/login';
      debugPrint('Auth login URL: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(),
            body: jsonEncode(request),
          )
          .timeout(_requestTimeout);

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
            headers: _getHeaders(),
            body: jsonEncode(request),
          )
          .timeout(_requestTimeout);

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

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.authBaseUrl}/auth/profile'),
            headers: _getHeaders(),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }

      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to fetch profile');
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final request = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
      };

      final response = await http
          .put(
            Uri.parse('${ApiConfig.authBaseUrl}/auth/profile'),
            headers: _getHeaders(),
            body: jsonEncode(request),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }

      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to update profile');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
}
