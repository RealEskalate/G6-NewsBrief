import 'package:newsbrief/features/news/domain/entities/news.dart';

class NewsModel extends News {
  NewsModel({
    required super.id,
    required super.title,
    required super.body,
    required super.language,
    required super.sourecId,
    required super.topics,
    required super.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      language: json['language'] ?? '',
      sourecId: json['source_id'] ?? '',
      topics:
          (json['topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "body": body,
      "language": language,
      "source_id": sourecId,
      "topics": topics,
      "published_at": publishedAt.toIso8601String(),
    };
  }
}
