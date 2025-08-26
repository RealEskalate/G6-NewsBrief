import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> signUp(User user);
  Future<List<String>> getAvailableInterests();
  User? get lastUser;
  void updateLastUser(User user);
}
