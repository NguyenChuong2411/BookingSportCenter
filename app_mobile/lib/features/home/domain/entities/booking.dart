class Booking {
  final String id;
  final String courtName;
  final String location;
  final DateTime date;
  final String time;
  final double rating;
  final String sportType;

  Booking({
    required this.id,
    required this.courtName,
    required this.location,
    required this.date,
    required this.time,
    required this.rating,
    required this.sportType,
  });
}
