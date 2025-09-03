import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class SubscribeToSources {
  final AuthRepository repo;
  SubscribeToSources(this.repo);

  Future<void> call({required String sourceSlug}) {
    return repo.subscribeToSource(sourceSlug: sourceSlug);
  }
}
