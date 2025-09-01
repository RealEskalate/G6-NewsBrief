
import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';

import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<AuthResponseEntity> call() async {
    return await repository.loginWithGoogle();
  }
}