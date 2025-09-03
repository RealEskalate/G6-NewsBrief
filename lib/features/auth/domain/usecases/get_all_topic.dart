import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetAllTopic {
  final AuthRepository repo;
  GetAllTopic(this.repo);

  Future<List<String>> call() {
    return repo.getAllTopics();
  }
}
