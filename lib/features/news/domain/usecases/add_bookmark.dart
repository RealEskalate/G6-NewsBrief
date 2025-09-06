import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class AddBookmark {
  final NewsRepository repository;

  AddBookmark(this.repository);

  Future<void> call(String newsId) async {
    return await repository.addBookmark(newsId);
  }
}