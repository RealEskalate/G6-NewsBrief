import '../entities/user.dart';
import '../entities/tokens.dart';

abstract class AuthRepository {
  Future<void> register({required String email, required String password, required String name});
  Future<Tokens> login({required String email, required String password});
  Future<void> logout({required String refreshToken});
  Future<User> getMe();
  Future<void> updateMe({required String name, required String email});

  Future<void> requestVerificationEmail({required String email});
  Future<void> verifyEmail({required String token});

  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String token, required String password});

  Future<Tokens> refreshToken({required String refreshToken});
}
