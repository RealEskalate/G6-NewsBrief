import 'package:newsbrief/features/news/domain/entities/bookmark.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class GetBookmark {
  final NewsRepository repository;

  GetBookmark(this.repository);

  Future<List<Bookmark>> call() async {
    return await repository.getBookmarks();
  }
}