import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

// LOGIN USE CASE
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<AuthResponseEntity> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
