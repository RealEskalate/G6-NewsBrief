import '../repositories/auth_repository.dart';

class GetInterestsUseCase {
  final AuthRepository repository;
  GetInterestsUseCase(this.repository);

  Future<List<String>> call() async {
    return repository.getAvailableInterests();
  }
}
