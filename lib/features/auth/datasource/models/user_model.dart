import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    required super.fullName,
    super.avatarUrl,
    required super.isVerified,
    required super.createdAt,
    super.interest,
    super.subscribedSources,
    required super.notification,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {

    // Safely parse created_at
    DateTime? createdAt;
    if (json['created_at'] != null && json['created_at'] is String) {
      try {
        createdAt = DateTime.parse(json['created_at'] as String);
      } catch (_) {
        createdAt = null;
      }
    }

    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      fullName: json['fullname'] ?? '',
      avatarUrl: json['avatar_url'],
      isVerified: json['is_verified'] ?? false,
      createdAt: createdAt,
      interest: (json['topics'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      subscribedSources: (json['subscribed_sources'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      notification: json['notification'] ?? false,
    );
  }
}
