import '../entities/source.dart';
import '../repositories/admin_repository.dart';

class CreateSourceUseCase {
  final AdminRepository repository;

  CreateSourceUseCase(this.repository);

  Future<void> call({
    required String slug,
    required String name,
    required String description,
    required String url,
    required String logoUrl,
    required String languages,
    required List<String> topics,
    required int reliabilityScore,
  }) async {
    final source = Source(
      slug: slug,
      name: name,
      description: description,
      url: url,
      logoUrl: logoUrl,
      languages: languages,
      topics: topics,
      reliabilityScore: reliabilityScore,
    );
    await repository.createSource(source);
  }
}
