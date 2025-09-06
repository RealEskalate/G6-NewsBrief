import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/features/auth/datasource/models/models.dart';
import 'package:newsbrief/features/auth/datasource/models/tokens_model.dart';
import 'package:newsbrief/features/auth/datasource/models/user_model.dart';

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
        data: {'email': email, 'password': password, 'fullname': name},
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

  Future<UserModel> getMe() async {
    try {
      final res = await api.get('/me');
      log("GetMe response: ${res.data}");
      return UserModel.fromJson(res.data as Map<String, dynamic>);
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        "662810615091-1h5hpu7ehtnvlo4bsnn934as57fjtqar.apps.googleusercontent.com",
  );

  Future<TokensModel> loginWithGoogle() async {
    try {
      // Step 1: Trigger Google Sign-In
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        print("❌ Google Sign-In threw an exception: $e");
      }

      if (googleUser == null) {
        print(
          "⚠️ Google Sign-In returned null (user canceled OR sign-in failed).",
        );
        return TokensModel(accessToken: '', refreshToken: '');
      }

      // Step 2: Get authentication details (ID token & access token)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        print("❌ Failed to get ID Token");
        return TokensModel(accessToken: '', refreshToken: '');
      }

      print("✅ Google ID Token: $idToken");
      print("✅ Google Access Token: $accessToken");

      final response = await api.post(
        '/auth/google/mobile/token',
        data: {"id_token": idToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        print("✅ Backend Response: $data");

        final serverAccessToken = data['access_token'];
        final serverRefreshToken = data['refresh_token'];

        print("🔑 Access Token: $serverAccessToken");
        print("🔑 Refresh Token: $serverRefreshToken");
        return TokensModel.fromJson(data);
      } else {
        print("❌ Server error: ${response.data}");
        return TokensModel(accessToken: '', refreshToken: '');
      }
    } catch (e) {
      print("❌ Google sign in failed: $e");
      return TokensModel(accessToken: '', refreshToken: '');
    }
  }

  Future<List<dynamic>> getSubscriptions() async {
    final response = await api.get("/me/subscriptions");
    print(response.data);
    return response.data["subscriptions"];
  }

  Future<void> subscribeToSources({required String sources}) async {
    try {
      final res = await api.post(
        "/me/subscriptions",
        data: {
          "source_key": sources, // ✅ match API schema
        },
      );
      print(res.data);
    } catch (e) {
      log("SubscribeToSources Exception: $e");
    }
  }

  Future<void> unSubscribeToSources({required String source}) async {
    try {
      final res = await api.delete("/me/subscriptions/$source");
      print(res);
    } catch (e) {
      log("UnSubscribeToSources $e");
    }
  }

  Future<List<dynamic>> getSubscribedTopics() async {
    try {
      final res = await api.get("/me/subscribed-topics");
      print(res.data);
      return res.data;
    } catch (e) {
      log("getSubscribedTopics $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getMyTopics() async {
    try {
      final res = await api.get("/me/topics");
      print(res.data);
      return res.data['topics'];
    } catch (e) {
      log("getMyTopics $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getAllSources() async {
    try {
      final res = await api.get("/sources");
      print(res.data);
      return res.data['sources'];
    } catch (e) {
      log("Sources $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getAllTopics() async {
    try {
      final res = await api.get("/topics");
      print(res.data);
      return res.data['topics'];
    } catch (e) {
      log("Topics $e");
      rethrow;
    }
  }

  Future<void> subscribeTopics(List<String> topicIds) async {
    try {
      await api.post('/me/topics', data: {'topics': topicIds});
    } catch (e) {
      log("SubscribeTopics $e");
      rethrow;
    }
  }

  Future<void> unsubscribeTopic(String topicId) async {
    try {
      await api.delete('/me/topics/$topicId');
    } catch (e) {
      log("UnsubscribeTopic $e");
      rethrow;
    }
  }
}
