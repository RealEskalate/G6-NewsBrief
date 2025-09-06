import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class RemoveBookmark {
  final NewsRepository repository;

  RemoveBookmark(this.repository);

  Future<void> call(String newsId) async {
    return await repository.removeBookmark(newsId);
  }
}