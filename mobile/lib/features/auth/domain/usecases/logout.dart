import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository repo;
  Logout(this.repo);

  Future<void> call({required String refreshToken}) =>
      repo.logout(refreshToken: refreshToken);
}
