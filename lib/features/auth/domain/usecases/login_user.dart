
import 'package:newsbrief/features/auth/domain/entities/tokens.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repo;
  LoginUser(this.repo);

  Future<Tokens> call({required String email, required String password}) {
    return repo.login(email: email, password: password);
  }
}
