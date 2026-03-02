import '../../domain/entities/court.dart';

class CourtModel extends Court {
  CourtModel({
    required super.id,
    required super.name,
    required super.location,
    required super.address,
    required super.rating,
    required super.reviewCount,
    required super.sportType,
    required super.imageUrl,
    required super.availableDates,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      sportType: json['sportType'] as String,
      imageUrl: json['imageUrl'] as String,
      availableDates: (json['availableDates'] as List<dynamic>)
          .map((date) => DateTime.parse(date as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'sportType': sportType,
      'imageUrl': imageUrl,
      'availableDates': availableDates
          .map((date) => date.toIso8601String())
          .toList(),
    };
  }
}
