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
    );
  }

  Map<String, dynamic> toJson() {
    final names = fullName.split(' ');
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': names.first,
      'last_name': names.length > 1 ? names.sublist(1).join(' ') : null,
      'role': role,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
