class Court {
  final String id;
  final String name;
  final String location;
  final String address;
  final double rating;
  final int reviewCount;
  final String sportType;
  final String imageUrl;
  final List<DateTime> availableDates;

  Court({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.sportType,
    required this.imageUrl,
    required this.availableDates,
  });
}
