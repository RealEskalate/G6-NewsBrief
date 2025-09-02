import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/features/auth/datasource/models/models.dart';
import 'package:newsbrief/features/auth/datasource/models/tokens_model.dart';

class AuthRemoteDataSources {
  final ApiService api;

  AuthRemoteDataSources(this.api);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final res = await api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      print('Login Response: ${res.data}');
      return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      final res = await api.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'full_name': name},
      );
      print('Register Response: ${res.data}');
    } catch (e) {
      print('Register Error: $e');
      rethrow;
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      final res = await api.post(
        '/logout',
        data: {'refresh_token': refreshToken},
      );
      log("Logout response: $res");
    } catch (e, s) {
      log("Logout failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<AuthResponseModel> getMe() async {
    try {
      final res = await api.get('/me');
      log("GetMe response: ${res.data}");
      return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e, s) {
      log("GetMe failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<void> updateMe(String name, String email) async {
    try {
      final res = await api.put('/me', data: {'name': name, 'email': email});
      log("UpdateMe response: $res");
    } catch (e, s) {
      log("UpdateMe failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<void> requestVerifacationEmail(String email) async {
    try {
      final res = await api.post(
        '/auth/request-verification-email',
        data: {'email': email},
      );
      log("RequestVerificationEmail response: $res");
    } catch (e, s) {
      log("RequestVerificationEmail failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<TokensModel> verifyEmail(String token) async {
    try {
      final res = await api.get('/auth/verify-email', query: {'token': token});
      log("VerifyEmail response: ${res.data}");
      return TokensModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e, s) {
      log("VerifyEmail failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<void> forgotpassword(String email) async {
    try {
      final res = await api.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      log("ForgotPassword response: ${res.data}");
    } on DioException catch (e, s) {
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 400:
            log("Invalid email address: ${e.response?.data}");
            throw Exception("Invalid email. Please check and try again.");
          case 404:
            log("Email not found: ${e.response?.data}");
            throw Exception("No account found with this email.");
          case 503:
            log("Service unavailable: ${e.response?.data}");
            throw Exception("Server is unavailable. Please try again later.");
          default:
            log(
              "Unexpected error: ${e.response?.statusCode} -> ${e.response?.data}",
            );
            throw Exception("Something went wrong. Please try again.");
        }
      } else {
        log("Network/Connection error: $e", stackTrace: s);
        throw Exception("Couldn’t connect to the server. Check your internet.");
      }
    } catch (e, s) {
      log("ForgotPassword failed: $e", stackTrace: s);
      throw Exception("Unexpected error. Please try again.");
    }
  }

  Future<void> resetPassword(String token, String password) async {
    try {
      final res = await api.post(
        '/auth/reset-password',
        data: {'token': token, 'password': password},
      );
      log("ResetPassword response: $res");
    } catch (e, s) {
      log("ResetPassword failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<TokensModel> refreshToken(String refreshToken) async {
    try {
      final res = await api.post(
        '/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );
      log("RefreshToken response: ${res.data}");
      return TokensModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e, s) {
      log("RefreshToken failed: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<AuthResponseModel> loginWithGoogle() async {
    final loginUrl = Uri.parse(
      "https://news-brief-core-api-excr.onrender.com/api/v1/auth/google/login",
    );

    // Open Google login in a browser
    final result = await FlutterWebAuth2.authenticate(
      url: loginUrl.toString(),
      callbackUrlScheme: "myapp", // must match Android/iOS scheme
    );

    // Parse returned callback URL
    final callbackUri = Uri.parse(result);
    final accessToken = callbackUri.queryParameters['access_token'];
    final refreshToken = callbackUri.queryParameters['refresh_token'];
    final userJson = callbackUri.queryParameters['userId'];

    if (accessToken == null || refreshToken == null) {
      throw Exception("Failed to retrieve tokens from Google login");
    }

    print('accessToken: $accessToken');
    print('refreshToken: $refreshToken');
    print('userJson: $userJson');

    return AuthResponseModel.fromJson({
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "user": userJson != null ? jsonDecode(userJson) : null,
    });
  }
}
