import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/court.dart';

class CenterService {
  static String get baseUrl {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 'http://localhost:5253/api';
    }

    return 'http://10.0.2.2:5253/api';
  }

  Future<List<Court>> fetchAvailableCenters() async {
    try {
      final url = Uri.parse('$baseUrl/Center/available');
      log('Fetching centers from $url');

      final response = await http.get(url);
      log('Centers response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList
            .map(
              (json) => Court(
                id: json['id'].toString(),
                name: json['name'] ?? 'Unknown',
                location: json['location'] ?? 'Location',
                address: json['address'] ?? '',
                rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
                reviewCount: json['reviewCount'] ?? 0,
                sportType: json['sportType'] ?? 'Football',
                imageUrl: json['imageUrl'] ?? '',
                availableDates: [],
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load courts: ${response.statusCode}');
      }
    } catch (e) {
      log('Lỗi khi gọi API: $e');
      return [];
    }
  }
}
