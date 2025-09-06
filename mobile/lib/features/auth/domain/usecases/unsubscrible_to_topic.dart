import 'package:newsbrief/features/auth/domain/repositories/auth_repository.dart';

class UnsubscribeFromTopic {
  final AuthRepository repository;

  UnsubscribeFromTopic(this.repository);

  Future<void> call(String topicId) async {
    await repository.unsubscribeTopic(topicId);
  }
}