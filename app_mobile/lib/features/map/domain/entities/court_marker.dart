import 'package:latlong2/latlong.dart';

/// Domain entity for court location marker
/// This structure matches backend data model for easy integration
class CourtMarker {
  final String id;
  final String courtName;
  final String
  sportType; // 'Football', 'Tennis', 'Basketball', 'Volleyball', etc.
  final LatLng location;
  final String address;
  final double rating;
  final int reviewCount;
  final double pricePerHour;
  final List<String> facilities; // ['Parking', 'Shower', 'Locker', etc.]
  final bool isAvailable;

  const CourtMarker({
    required this.id,
    required this.courtName,
    required this.sportType,
    required this.location,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.facilities,
    required this.isAvailable,
  });

  /// Factory constructor for backend JSON data
  factory CourtMarker.fromJson(Map<String, dynamic> json) {
    return CourtMarker(
      id: json['id'] as String,
      courtName: json['court_name'] as String,
      sportType: json['sport_type'] as String,
      location: LatLng(json['latitude'] as double, json['longitude'] as double),
      address: json['address'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      facilities: List<String>.from(json['facilities'] as List),
      isAvailable: json['is_available'] as bool,
    );
  }

  /// Convert to JSON for backend sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court_name': courtName,
      'sport_type': sportType,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'rating': rating,
      'review_count': reviewCount,
      'price_per_hour': pricePerHour,
      'facilities': facilities,
      'is_available': isAvailable,
    };
  }
}
