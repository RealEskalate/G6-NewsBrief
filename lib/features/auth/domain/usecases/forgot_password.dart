import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repo;
  ForgotPassword(this.repo);

  Future<void> call({required String email}) =>
      repo.forgotPassword(email: email);
}
