class ChatMessage {
  final String newsId; // optional for general chat
  final String message;
  final String? reply;

  ChatMessage({required this.message, required this.newsId, this.reply, required bool isUser});

}
