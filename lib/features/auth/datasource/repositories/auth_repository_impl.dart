import 'dart:developer';
import 'package:newsbrief/features/auth/datasource/datasources/auth_local_data_sourcs.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_remote_data_sources.dart';
import 'package:newsbrief/features/auth/datasource/models/models.dart';
import 'package:newsbrief/features/auth/datasource/models/tokens_model.dart';
import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';
import 'package:newsbrief/features/auth/domain/entities/tokens.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSources remote;
  final AuthLocalDataSource local;
  AuthRepositoryImpl({required this.remote, required this.local});

  final List<User> _users = [];

  final List<User> _predefinedUsers = [
    User(
      fullName: "Test User",
      email: "test@example.com",
      password: "password123",
      interests: ['Technology', 'Sports'],
    ),
    User(
      fullName: "Demo User",
      email: "demo@example.com",
      password: "demo123",
      interests: ['Business', 'Health'],
    ),
  ];
  final List<String> _dummyInterests = [
    'Technology',
    'Business',
    'Politics',
    'Health',
    'Entertainment',
    'Sports',
    'Science',
    'Travel',
    'Food',
    'Art',
    'Fashion',
    'Education',
    'Music',
    'Movies',
    'Gaming',
    'Lifestyle',
    'Environment',
    'History',
    'Finance',
    'Photography',
    'Culture',
    'Wellness',
    'DIY',
    'Politics & Law',
    'Automotive',
    'Relationships',
    'Spirituality',
    'Fitness',
    'Animals',
    'Comics & Animation',
    'Technology Startups',
  ];

  @override
  Future<void> signUp(User user) async {
    try {
      if (user.fullName.isEmpty ||
          user.email.isEmpty ||
          user.password.isEmpty) {
        throw Exception('Full Name, Email, and Password cannot be empty');
      }
      _users.add(user);
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<User> Login({required String email, required String password}) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password can not be empty');
      }

      await Future.delayed(const Duration(seconds: 1));

      // Check in predefined users first
      try {
        final predefinedUser = _predefinedUsers.firstWhere(
          (user) => user.email == email && user.password == password,
        );
        return predefinedUser;
      } catch (e) {
        // If not found in predefined users, check in registered users
        try {
          final registeredUser = _users.firstWhere(
            (user) => user.email == email && user.password == password,
          );
          return registeredUser;
        } catch (e) {
          throw Exception('Invalid email or password');
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> getAvailableInterests() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _dummyInterests;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  User? get lastUser => _users.isNotEmpty ? _users.last : null;

  @override
  void updateLastUser(User user) {
    if (_users.isNotEmpty)
      _users[_users.length - 1] = user;
    else
      _users.add(user);
  }

  @override
  Future<User> signUpWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final user = User(
        fullName: "Google User",
        email: "dummy.google.user@gmail.com",
        password: "google_dummy_password", // not real, just placeholder
      );
      _users.add(user);
      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> loginWithGoogle() async {
    try {
      final response = await remote.signInWithGoogle();
      return AuthResponseModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      return await remote.forgotpassword(email);
    } catch (e, stack) {
      log("Error in forgotPassword: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<AuthResponseEntity> getMe() async {
    try {
      return await remote.getMe();
    } catch (e, stack) {
      log("Error in getMe: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await remote.logout(refreshToken);
    } catch (e, stack) {
      log("Error in logout: $e", stackTrace: stack);
      rethrow;
    } finally {
      await local.clear();
    }
  }

  @override
  Future<Tokens> refreshToken({required String refreshToken}) async {
    try {
      final TokensModel tokens = await remote.refreshToken(refreshToken);
      await local.cacheTokens(
        access: tokens.accessToken,
        refresh: tokens.refreshToken,
      );
      return tokens;
    } catch (e, stack) {
      log("Error in refreshToken: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> requestVerificationEmail({required String email}) async {
    try {
      return await remote.requestVerifacationEmail(email);
    } catch (e, stack) {
      log("Error in requestVerificationEmail: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      return await remote.resetPassword(token, password);
    } catch (e, stack) {
      log("Error in resetPassword: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<void> updateMe({required String name, required String email}) async {
    try {
      return await remote.updateMe(name, email);
    } catch (e, stack) {
      log("Error in updateMe: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<Tokens> verifyEmail({required String token}) async {
    try {
      final tokens = await remote.verifyEmail(token);
      await local.cacheTokens(
        access: tokens.accessToken,
        refresh: tokens.refreshToken,
      );
      return tokens;
    } catch (e, stack) {
      log("Error in verifyEmail: $e", stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await remote.login(email, password);

      final user = UserEntity(
        id: res.user.id,
        username: res.user.username,
        email: res.user.email,
        role: res.user.role,
        fullName: res.user.fullName,
        avatarUrl: res.user.avatarUrl,
        isVerified: res.user.isVerified,
        createdAt: res.user.createdAt,
      );
      await local.cacheTokens(
        access: res.accessToken,
        refresh: res.refreshToken,
      );
      return AuthResponseEntity(
        user: user,
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
    } catch (e) {
      print('Repository Login Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await remote.register(email, password, name);
    } catch (e) {
      print('Repository Register Error: $e');
      rethrow;
    }
  }
}
