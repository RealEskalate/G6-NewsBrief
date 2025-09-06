import 'package:newsbrief/features/news/domain/entities/bookmark.dart';
import 'package:newsbrief/features/news/domain/entities/chat_message.dart';
import 'package:newsbrief/features/news/domain/entities/news.dart';

abstract class NewsRepository {
  Future<List<News>> getTrendingNews({int page = 1, int limit = 10});
  Future<List<News>> getTodayNews();
  Future<List<News>> getForYouNews({int page = 1, int limit = 10});
  Future<List<News>> getNewsByTopic(
    String topicId, {
    int page = 1,
    int limit = 10,
  });

  Future<void> addBookmark(String newsId);
  Future<void> removeBookmark(String newsId);
  Future<List<Bookmark>> getBookmarks();


  Future<ChatMessage> generalChat(String message);
  Future<ChatMessage> newsChat(String newsId, String message);

}
