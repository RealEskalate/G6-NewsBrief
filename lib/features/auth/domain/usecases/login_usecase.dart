// domain/usecases/login_usecase.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call({required String email, required String password}) {
    return repository.Login(email:email, password:password);
  }
}
