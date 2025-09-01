import '../../domain/entities/auth_entities.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  AuthResponseModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
  final userModel = UserModel.fromJson(json['user'] as Map<String, dynamic>);
  return AuthResponseModel(
    user: userModel as UserEntity, // explicitly cast to User
    accessToken: json['access_token'] ?? '',
    refreshToken: json['refresh_token'] ?? '',
  );
}

}
