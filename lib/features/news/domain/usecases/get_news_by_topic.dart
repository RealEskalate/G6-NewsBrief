import 'package:newsbrief/features/news/domain/entities/news.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class GetNewsByTopic {
  final NewsRepository repository;
  GetNewsByTopic(this.repository);

  Future<List<News>> call(
    String topicId, {
    int page = 1,
    int limit = 10,
  }) {
    return repository.getNewsByTopic(
      topicId,
      page: page,
      limit: limit,
    );
  }
}