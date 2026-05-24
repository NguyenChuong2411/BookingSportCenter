import '../../domain/entities/user_profile.dart';

/// Data model for user profile with JSON serialization
/// Matches backend API response structure
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.avatarUrl,
    required super.role,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create UserProfileModel from backend JSON response
  /// Expected API endpoint: GET /api/users/{id} or GET /api/auth/profile
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'] ?? json['created_at'];
    final updatedAtValue =
        json['updatedAt'] ?? json['updated_at'] ?? createdAtValue;

    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: (json['fullName'] ?? json['full_name']) as String,
      phoneNumber: (json['phoneNumber'] ?? json['phone_number']) as String?,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      role: json['role'] as String? ?? 'Customer',
      isActive: (json['isActive'] ?? json['is_active']) as bool? ?? true,
      createdAt: DateTime.parse(createdAtValue as String),
      updatedAt: DateTime.parse(updatedAtValue as String),
    );
  }

  /// Convert to JSON for backend requests
  /// Used for PUT /api/users/{id} - Update profile
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to update request JSON (only editable fields)
  /// Used for PATCH /api/users/{id} - Partial update
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
    };
  }

  /// Convert from UserProfile entity to model
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      username: profile.username,
      email: profile.email,
      fullName: profile.fullName,
      phoneNumber: profile.phoneNumber,
      avatarUrl: profile.avatarUrl,
      role: profile.role,
      isActive: profile.isActive,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}
