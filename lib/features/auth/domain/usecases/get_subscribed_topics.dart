import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetSubscribedTopics {
  final AuthRepository repo;
  GetSubscribedTopics(this.repo);

  Future<List<Map<String, dynamic>>> call() {
    return repo.getSubscribedTopics();
  }
}
