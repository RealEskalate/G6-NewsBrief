
import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';
// REGISTER USE CASE
class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<AuthResponseEntity> call({required String email,required String password,required String name}) {
    return repository.register(email: email, password: password, name: name);
  }
}