import 'package:newsbrief/features/news/domain/entities/news.dart';



abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoadeds extends NewsState {
  final List<News> forYouNews;
  final Map<String, List<News>> topicNews;

  NewsLoadeds({required this.forYouNews, Map<String, List<News>>? topicNews})
      : topicNews = topicNews ?? {};
}


class NewsLoaded extends NewsState {
  final List<News> news;
  NewsLoaded(this.news);
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);
}

