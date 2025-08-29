import 'package:newsbrief/features/auth/domain/entities/tokens.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class RefreshToken {
  final AuthRepository repo;
  RefreshToken(this.repo);

  Future<Tokens> call({required String refreshToken}) {
    return repo.refreshToken(refreshToken: refreshToken);
  }
}
