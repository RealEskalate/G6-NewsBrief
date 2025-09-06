class News {
  final String id;
  final String title;
  final String body;
  final String language;
  final String soureceId;
  final List<String> topics;
  final DateTime publishedAt;

  News({
    required this.id,
    required this.title,
    required this.body,
    required this.language,
    required this.soureceId,
    required this.topics,
    required this.publishedAt,
  });
  
}
