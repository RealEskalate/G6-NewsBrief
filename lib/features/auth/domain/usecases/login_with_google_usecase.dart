// domain/usecases/login_with_google_usecase.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<User> call() {
    return repository.loginWithGoogle();
  }
}