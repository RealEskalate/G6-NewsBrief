import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class RequestVerificationEmail {
  final AuthRepository repo;
  RequestVerificationEmail(this.repo);

  Future<void> call({required String email}) =>
      repo.requestVerificationEmail(email: email);
}
