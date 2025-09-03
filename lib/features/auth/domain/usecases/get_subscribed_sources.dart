import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class GetSubscribedSources {
  final AuthRepository repo;
  GetSubscribedSources(this.repo);

  Future<List<String>> call() {
    return repo.getSubscribedSources();
  }
}
