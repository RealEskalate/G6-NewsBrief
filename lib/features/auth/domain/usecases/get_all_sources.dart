import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetAllSources {
  final AuthRepository repo;
  GetAllSources(this.repo);

  Future<List<Map<String, dynamic>>> call() {
    return repo.getAllSources();
  }
}
