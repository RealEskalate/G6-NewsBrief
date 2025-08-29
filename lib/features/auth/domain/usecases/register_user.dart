import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repo;
  RegisterUser(this.repo);

  Future<void> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repo.register(email: email, password: password, name: name);
  }
}
