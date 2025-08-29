import 'package:newsbrief/features/auth/domain/entities/user.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetMe {
  final AuthRepository repo;
  GetMe(this.repo);

  Future<User> call() => repo.getMe();
}
