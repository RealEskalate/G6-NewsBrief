import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/features/news/datasource/models/news_model.dart';

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
}
