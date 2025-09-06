
import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class UnsubscribeFromSource {
  final AuthRepository repo;
  UnsubscribeFromSource(this.repo);

  Future<void> call({required String sourceSlug}){
    return repo.unsubscribeFromSource(sourceSlug: sourceSlug);
  }
}
