import 'package:newsbrief/features/news/domain/entities/news.dart';

class NewsModel extends News {
  NewsModel({
    required super.id,
    required super.title,
    required super.body,
    required super.language,
    required super.soureceId,
    required super.topics,
    required super.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      language: json['language'],
      soureceId: json['source_id'],
      topics: List<String>.from(json['topics']),
      publishedAt: DateTime.parse(json['published_at']),
    );
  }

   Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "body": body,
      "language": language,
      "source_id": soureceId,
      "topics": topics,
      "published_at": publishedAt.toIso8601String(),
    };
  }
}
