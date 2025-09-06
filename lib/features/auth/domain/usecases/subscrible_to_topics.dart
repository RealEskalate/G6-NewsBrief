import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class SubscribeToTopics {
  final AuthRepository repository;

  SubscribeToTopics(this.repository);

  Future<void> call(List<String> topicIds) async {
    await repository.subscribeTopics(topicIds);
  }
}