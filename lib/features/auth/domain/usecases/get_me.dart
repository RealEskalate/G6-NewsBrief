import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetMe {
  final AuthRepository repo;
  GetMe(this.repo);

  Future<UserEntity> call() => repo.getMe();
}
