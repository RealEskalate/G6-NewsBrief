import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';

abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  String message;
  ChatLoaded(this.message);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatCubit extends Cubit<ChatState> {
  final NewsRepository repository;

  ChatCubit(this.repository) : super(ChatInitial());

 Future<void> sendGeneralMessage(String message) async {
  emit(ChatLoading());
  try {
    final res = await repository.generalChat(message);
    // Assuming ChatMessage has a field called `message` that contains the text
    emit(ChatLoaded(res.message));
  } catch (e) {
    emit(ChatError(e.toString()));
  }
}

Future<void> sendNewsMessage(String newsId, String message) async {
  emit(ChatLoading());
  try {
    final res = await repository.newsChat(newsId, message);
    emit(ChatLoaded(res.message));
  } catch (e) {
    emit(ChatError(e.toString()));
  }
}

}
