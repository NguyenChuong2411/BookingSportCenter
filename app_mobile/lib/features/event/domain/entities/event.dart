/// Domain entity for promotional events and tournaments
/// Events are campaigns created by courts to attract customers
class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String courtId;
  final String courtName;
  final String eventType; // 'promotion', 'tournament', 'special_offer'
  final DateTime startDate;
  final DateTime endDate;
  final String? discount; // e.g., "60% OFF", "FREE 1 HOUR"
  final double? originalPrice;
  final double? discountedPrice;
  final String? location;
  final bool isActive;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.courtId,
    required this.courtName,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    this.discount,
    this.originalPrice,
    this.discountedPrice,
    this.location,
    required this.isActive,
    required this.createdAt,
  });

  /// Check if event is currently active based on dates
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Get formatted discount text
  String get discountText {
    if (discount != null) return discount!;
    if (originalPrice != null && discountedPrice != null) {
      final percent =
          ((originalPrice! - discountedPrice!) / originalPrice! * 100).round();
      return '$percent% OFF';
    }
    return 'Special Offer';
  }

  /// Create a copy with updated fields
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? courtId,
    String? courtName,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? discount,
    double? originalPrice,
    double? discountedPrice,
    String? location,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      discount: discount ?? this.discount,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
