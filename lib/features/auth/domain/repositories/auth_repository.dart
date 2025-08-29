import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> signUp(User user);
  Future<User> login(String email, String password);
  Future<List<String>> getAvailableInterests();
  User? get lastUser;
  void updateLastUser(User user);
  Future<User> signUpWithGoogle();
  Future<User> loginWithGoogle();
}
