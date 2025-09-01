
import 'package:newsbrief/features/auth/domain/entities/tokens.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmail {
  final AuthRepository repo;
  VerifyEmail(this.repo);

  Future<Tokens> call({required String token}) async {
    return repo.verifyEmail(token: token);
  }
}
