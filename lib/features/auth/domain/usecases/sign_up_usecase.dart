import '../entities/user.dart';
import '../repositories/auth_repository.dart';


class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<void> call(User user) async {
    return repository.signUp(user);
  }
}