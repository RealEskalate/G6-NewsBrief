import 'package:newsbrief/features/auth/domain/entities/tokens.dart';

class TokensModel extends Tokens {
  TokensModel({required super.accessToken, required super.refreshToken});
  factory TokensModel.fromJson(Map<String, dynamic> json) {
    return TokensModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }
}
