import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../news/datasource/models/news_model.dart';


class LocalNewsRepository {
  static const _newsKey = 'local_news';

  /// Add a news item locally
  Future<void> addNews(News news) async {
    final prefs = await SharedPreferences.getInstance();
    final currentNews = prefs.getStringList(_newsKey) ?? [];

    // Convert News object to JSON string
    currentNews.add(jsonEncode(news.toJson()));

    await prefs.setStringList(_newsKey, currentNews);
  }

  /// Get all locally stored news
  Future<List<News>> getAllNews() async {
    final prefs = await SharedPreferences.getInstance();
    final currentNews = prefs.getStringList(_newsKey) ?? [];

    return currentNews
        .map((newsString) => News.fromJson(jsonDecode(newsString)))
        .toList();
  }

  /// Clear all locally stored news
  Future<void> clearAllNews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newsKey);
  }
}
