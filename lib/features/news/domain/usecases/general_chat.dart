import 'package:newsbrief/features/news/domain/entities/chat_message.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

class GeneralChat {
  final NewsRepository repository;

  GeneralChat(this.repository);

  Future<ChatMessage> call(String message) async {
    return await repository.generalChat(message);
  } 
}