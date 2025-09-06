import 'package:newsbrief/features/news/domain/entities/news.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class GetTrendingNews {
  final NewsRepository repository;
  GetTrendingNews(this.repository);

  Future<List<News>> call({int page = 1, int limit = 10}) {
    return repository.getTrendingNews(page: page, limit: limit);
  }
}