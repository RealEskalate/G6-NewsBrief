class Bookmark {
  final String newsId;
  final bool isBookmarked;
  final String title;
  final String body;
  final String language;
  final String soureceId;
  final List<String> topics;

  Bookmark(this.title, this.body, this.language, this.soureceId, this.topics, {required this.newsId, this.isBookmarked = true});
}
