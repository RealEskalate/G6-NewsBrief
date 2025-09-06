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
      final response = await remote.loginWithGoogle();
      await local.cacheTokens(
        access: response.accessToken,
        refresh: response.refreshToken,
      );
      final user = await remote.getMe();
      final AuthResponse = AuthResponseModel(
        user: user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return AuthResponseModel.fromJson(AuthResponse as Map<String, dynamic>);
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
  Future<UserEntity> getMe() async {
    try {
      return await remote.getMe();
      // return AuthResponseModel.fromJson(user as Map<String, dynamic>);
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
  Future<UserEntity> updateMe({required String name}) async {
    return await remote.updateMe(name);
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
  Future<AuthResponseModel> login({
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
        notification: res.user.notification,
      );
      await local.cacheTokens(
        access: res.accessToken,
        refresh: res.refreshToken,
      );
      return AuthResponseModel(
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
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await remote.register(email, password, name);

      final res = await remote.login(email, password);

      return AuthResponseModel(
        user: res.user,
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
    } catch (e) {
      print('Repository Register Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getSubscribedSources() async {
    final subs = await remote.getSubscriptions();
    return subs.map((e) => e["source_slug"] as String).toList();
  }

  @override
  Future<void> subscribeToSource({required String sourceSlug}) async {
    await remote.subscribeToSources(sources: sourceSlug);
  }

  @override
  Future<void> unsubscribeFromSource({required String sourceSlug}) async {
    await remote.unSubscribeToSources(source: sourceSlug);
  }

  @override
  Future<List<Map<String, dynamic>>> getSubscribedTopics() async {
    final response = await remote.getSubscribedTopics();
    print(response.runtimeType); // should be List<dynamic>
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTopics() async {
    final response = await remote.getAllTopics();
    final topicsList = response;
    return topicsList.cast<Map<String, dynamic>>(); // keep as list of maps
  }

  @override
  Future<List<Map<String, dynamic>>> getAllSources() async {
    final response = await remote.getAllSources();
    final sourcesList = response;
    return sourcesList.cast<Map<String, dynamic>>(); // keep as list of maps
  }

  @override
  Future<void> subscribeTopics(List<String> topicIds) async {
    if (topicIds.isEmpty) return;
    await remote.subscribeTopics(topicIds);
  }

  @override
  Future<void> unsubscribeTopic(String topicId) async {
    await remote.unsubscribeTopic(topicId);
  }
}
