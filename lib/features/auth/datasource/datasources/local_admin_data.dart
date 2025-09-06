import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/source.dart';

class LocalAdminData {
  static const _topicsKey = 'local_topics';
  static const _sourcesKey = 'local_sources';

  // Topics
  static Future<void> addTopic(Topic topic) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_topicsKey) ?? [];

    // avoid duplicates by slug
    if (!current.any((t) => jsonDecode(t)['slug'] == topic.slug)) {
      current.add(jsonEncode(topic.toJson()));
      await prefs.setStringList(_topicsKey, current);
    }
  }

  static Future<List<Topic>> getTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_topicsKey) ?? [];
    return current.map((e) => Topic.fromJson(jsonDecode(e))).toList();
  }

  // Sources
  static Future<void> addSource(Source source) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_sourcesKey) ?? [];

    if (!current.any((s) => jsonDecode(s)['slug'] == source.slug)) {
      current.add(jsonEncode(source.toJson()));
      await prefs.setStringList(_sourcesKey, current);
    }
  }

  static Future<List<Source>> getSources() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_sourcesKey) ?? [];
    return current.map((e) => Source.fromJson(jsonDecode(e))).toList();
  }
}
