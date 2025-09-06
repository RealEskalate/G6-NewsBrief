import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/features/news/datasource/models/models.dart';
import 'package:newsbrief/features/news/datasource/models/news_model.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';

class NewsRemoteDataSources {
  final ApiService api;

  NewsRemoteDataSources(this.api);

  Future<List<NewsModel>> getTrendingNews({int page = 1, int limit = 10}) async {
    try {
      final res = await api.get('/news/trending', query: {
        'page': page,
        'limit': limit,
      });
      print('Trending News Response: ${res.data}');

      final List<dynamic> data = (res.data['news'] as List<dynamic>?) ?? [];
      return data.map((e) => NewsModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Trending News Error: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> getForYouNews({int page = 1, int limit = 10}) async {
    try {
      final res = await api.get('/me/for-you', query: {
        'page': page,
        'limit': limit,
      });
      print('For You News Response: ${res.data}');

      final List<dynamic> data = (res.data['news'] as List<dynamic>?) ?? [];
      return data.map((e) => NewsModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('For You News Error: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> getTodayNews() async {
    try {
      final res = await api.get('/news/today');
      print('Today News Response: ${res.data}');

      final List<dynamic> data = (res.data['news'] as List<dynamic>?) ?? [];
      return data.map((e) => NewsModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Today News Error: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> getNewsByTopic(
    String topicId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await api.get('/topics/$topicId/news', query: {
        'page': page,
        'limit': limit,
      });
      print('News By Topic Response: ${res.data}');

      final List<dynamic> data = (res.data['news'] as List<dynamic>?) ?? [];
      return data.map((e) => NewsModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('News By Topic Error: $e');
      rethrow;
    }
  }

  Future<void> addBookmark(String newsId) async {
    await api.post('/me/bookmarks', data: {'news_id': newsId});
  }

  Future<void> removeBookmark(String newsId) async {
    await api.delete('/me/bookmarks/$newsId');
  }

  Future<List<BookmarkModel>> getBookmarks() async {
    final res = await api.get('/me/bookmarks');
    final List<dynamic> data = (res.data['news'] as List<dynamic>?) ?? [];
    return data.map((e) => BookmarkModel.fromJson(e)).toList();
  }

   Future<ChatMessage> generalChat(String message) async {
  final res = await api.post('/chat/general', data: {'message': message});
  final replyText = res.data['reply']; // This is already a String
  return ChatMessage(
    message: replyText,
    isUser: false,
    newsId: '',
  );
}

Future<ChatMessage> newsChat(String newsId, String message) async {
  final res = await api.post('/chat/news/$newsId', data: {'message': message});
  final replyText = res.data['reply']; // Already a String
  return ChatMessage(
    message: replyText,
    isUser: false,
    newsId: newsId,
  );
}

}
