class UserEntity {
  final String id;
  final String username;
  final String email;
  final String role;
  final String fullName;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? createdAt;
  List<String>? interest;
  List<String>? subscribedSources;
  final Map<String, dynamic> notification;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.fullName,
    this.avatarUrl,
    required this.isVerified,
    this.createdAt,
    this.interest,
    this.subscribedSources,
    required this.notification,
  });
}

class AuthResponseEntity {
  final UserEntity user;
  final String accessToken;
  final String refreshToken;

  AuthResponseEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  set interest(List<String> interest) {}
}
