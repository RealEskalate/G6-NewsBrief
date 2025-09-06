import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class UpdateMe {
  final AuthRepository repository;

  UpdateMe(this.repository);

  Future<UserEntity> call({required String name}) async {
    return await repository.updateMe(name: name);
  }
}