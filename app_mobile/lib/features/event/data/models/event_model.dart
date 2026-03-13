import '../../domain/entities/event.dart';

/// Data model for Event with JSON serialization
/// Matches backend API response structure
class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.courtId,
    required super.courtName,
    required super.eventType,
    required super.startDate,
    required super.endDate,
    super.discount,
    super.originalPrice,
    super.discountedPrice,
    super.location,
    required super.isActive,
    required super.createdAt,
  });

  /// Create EventModel from backend JSON response
  /// Expected API endpoint: GET /api/events or GET /api/events/{id}
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      courtId: json['court_id'] as String,
      courtName: json['court_name'] as String,
      eventType: json['event_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      discount: json['discount'] as String?,
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      location: json['location'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for backend requests
  /// Used for POST /api/events - Create event
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'court_id': courtId,
      'court_name': courtName,
      'event_type': eventType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'discount': discount,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'location': location,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert from Event entity to model
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      imageUrl: event.imageUrl,
      courtId: event.courtId,
      courtName: event.courtName,
      eventType: event.eventType,
      startDate: event.startDate,
      endDate: event.endDate,
      discount: event.discount,
      originalPrice: event.originalPrice,
      discountedPrice: event.discountedPrice,
      location: event.location,
      isActive: event.isActive,
      createdAt: event.createdAt,
    );
  }
}
