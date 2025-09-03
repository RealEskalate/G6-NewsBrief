import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetSubscribedTopics {
  final AuthRepository repo;
  GetSubscribedTopics(this.repo);

  Future<List<String>> call() {
    return repo.getSubscribedTopics();
  }
}
