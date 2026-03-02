import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  BookingModel({
    required super.id,
    required super.courtName,
    required super.location,
    required super.date,
    required super.time,
    required super.rating,
    required super.sportType,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      courtName: json['courtName'] as String,
      location: json['location'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      rating: (json['rating'] as num).toDouble(),
      sportType: json['sportType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courtName': courtName,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'rating': rating,
      'sportType': sportType,
    };
  }
}
