import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repo;
  ResetPassword(this.repo);

  Future<void> call({required String token, required String password}) =>
      repo.resetPassword(token: token, password: password);
}
