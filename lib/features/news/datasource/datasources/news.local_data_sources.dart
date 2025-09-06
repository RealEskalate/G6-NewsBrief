import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<void> cacheNews(String key, List<NewsModel> news);
  Future<List<NewsModel>> getCachedNews(String key);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final SharedPreferences prefs;

  NewsLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheNews(String key, List<NewsModel> news) async {
    final jsonList = news.map((n) => json.encode(n.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  @override
  Future<List<NewsModel>> getCachedNews(String key) async {
    final jsonList = prefs.getStringList(key);
    if (jsonList == null) return [];
    return jsonList.map((e) => NewsModel.fromJson(json.decode(e))).toList();
  }
}
