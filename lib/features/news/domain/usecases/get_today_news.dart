import 'package:newsbrief/features/news/domain/entities/news.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class GetTodayNews {
  final NewsRepository repository;
  GetTodayNews(this.repository);

  Future<List<News>> call() {
    return repository.getTodayNews();
  }
}