import 'package:newsbrief/features/news/domain/entities/chat_message.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class NewsChat {
  final NewsRepository repository;

  NewsChat(this.repository);

  Future<ChatMessage> call(String newsId, String message) {
    return repository.newsChat(newsId, message);
  }
}