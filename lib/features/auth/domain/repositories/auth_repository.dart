import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';
import 'package:newsbrief/features/auth/domain/entities/tokens.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  });
  Future<void> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout({required String refreshToken});
  Future<UserEntity> getMe();
  Future<void> updateMe({required String name, required String email});

  Future<void> requestVerificationEmail({required String email});
  Future<Tokens> verifyEmail({required String token});

  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String token, required String password});

  Future<Tokens> refreshToken({required String refreshToken});

  Future<void> signUp(User user);
  Future<User> Login({required String email, required String password});
  Future<List<String>> getAvailableInterests();
  User? get lastUser;
  void updateLastUser(User user);
  Future<User> signUpWithGoogle();
  Future<AuthResponseEntity> loginWithGoogle();
}
