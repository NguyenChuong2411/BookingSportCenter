import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'api_config.dart';

class BookingApiService {
  static String get baseUrl => ApiConfig.bookingBaseUrl;

  // Lưu JWT token từ login
  static String? _jwtToken;

  // Setter để lưu token sau khi login
  static void setJwtToken(String token) {
    _jwtToken = token;
  }

  // Getter cho token
  static String? getJwtToken() => _jwtToken;

  // Helper để tạo headers với JWT
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
    };
  }

  // ==================== CENTERS ====================

  /// Lấy danh sách sân tập có sẵn
  static Future<List<Map<String, dynamic>>> getAvailableCenters() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/center/available'), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch centers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching centers: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết sân
  static Future<Map<String, dynamic>> getCenterDetails(String centerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/center/$centerId'), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch center: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching center: $e');
      rethrow;
    }
  }

  /// Lấy danh sách sân của một trung tâm
  static Future<List<Map<String, dynamic>>> getCenterCourts(
    String centerId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/center/$centerId/courts'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch courts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching courts: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết sân theo courtId
  static Future<Map<String, dynamic>> getCourtDetails(String courtId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/center/courts/$courtId'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch court: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching court: $e');
      rethrow;
    }
  }

  // ==================== BOOKINGS ====================

  /// Lấy danh sách khung giờ có sẵn
  static Future<List<Map<String, dynamic>>> getAvailableSlots(
    String courtId,
    DateTime date,
  ) async {
    try {
      final dateOnly = date.toIso8601String().split('T')[0];
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/booking/available-slots?courtId=$courtId&date=$dateOnly',
            ),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
          'Failed to fetch available slots: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching available slots: $e');
      rethrow;
    }
  }

  /// Tạo booking mới (KHÔNG TÍNH TIỀN SÂN)
  static Future<Map<String, dynamic>> createBooking({
    required String courtId,
    required DateTime bookingDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? note,
  }) async {
    try {
      final dateOnly = bookingDate.toIso8601String().split('T')[0];

      final request = {
        'courtId': courtId,
        'bookingDate': dateOnly,
        'startTime':
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
        'endTime':
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/booking'),
            headers: _getHeaders(),
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    }
  }

  /// Lấy danh sách booking của user
  static Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/booking/my-bookings'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch bookings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết booking
  static Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/booking/$bookingId'), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch booking: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      rethrow;
    }
  }

  /// Cập nhật booking
  static Future<Map<String, dynamic>> updateBooking({
    required String bookingId,
    required DateTime bookingDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    try {
      final dateOnly = bookingDate.toIso8601String().split('T')[0];

      final request = {
        'bookingDate': dateOnly,
        'startTime':
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
        'endTime':
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/booking/$bookingId'),
            headers: _getHeaders(),
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update booking');
      }
    } catch (e) {
      debugPrint('Error updating booking: $e');
      rethrow;
    }
  }

  /// Hủy booking
  static Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/booking/$bookingId'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      rethrow;
    }
  }

  /// Hoàn tất booking
  static Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/booking/$bookingId/complete'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to complete booking');
      }
    } catch (e) {
      debugPrint('Error completing booking: $e');
      rethrow;
    }
  }
}
