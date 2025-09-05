import '../entities/topic.dart';
import '../repositories/admin_repository.dart';

class CreateTopicUseCase {
  final AdminRepository repository;

  CreateTopicUseCase(this.repository);

  Future<void> call({
    required String slug,
    required Map<String, String> label, // required
    Map<String, String>? description,   // optional
  }) async {
    final topic = Topic(
      slug: slug,
      label: label,
      description: description,
    );
    await repository.createTopic(topic);
  }
}
