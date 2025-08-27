import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithGoogleUseCase {
  final AuthRepository repository;
  SignUpWithGoogleUseCase(this.repository);

  Future<User> call() async {
    return repository.signUpWithGoogle();
  }
}