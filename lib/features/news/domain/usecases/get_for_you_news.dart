import 'package:newsbrief/features/news/domain/entities/news.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class GetForYouNews {
  final NewsRepository repository;
  GetForYouNews(this.repository);
  
  Future<List<News>> call({int page = 1, int limit = 10}) {
    return repository.getForYouNews(page: page, limit: limit);
  }
}