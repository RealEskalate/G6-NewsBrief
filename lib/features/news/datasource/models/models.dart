import 'package:newsbrief/features/news/domain/entities/bookmark.dart';
import 'package:newsbrief/features/news/domain/entities/chat_message.dart';

class BookmarkModel extends Bookmark {
  BookmarkModel(super.title, super.body, super.language, super.soureceId, super.topics, {required super.newsId, required super.isBookmarked});

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      json['title'] ?? '',
      json['body'] ?? '',
      json['language'] ?? '',
      json['soureceId'] ?? '',
      (json['topics'] as List<dynamic>? ?? []).cast<String>(),
      newsId: json['id'] ?? '',
      isBookmarked: json['is_bookmarked'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'news_id': newsId};
}

// ignore: camel_case_types
class chatMessageModel extends ChatMessage {
  chatMessageModel({
    required super.message,
    required super.newsId,
    super.reply, required super.isUser,
  });

  factory chatMessageModel.fromJson(Map<String, dynamic> json) {
    return chatMessageModel(
      message: json['message'] ?? '',
      newsId: json['news_id'] ?? '',
      reply: json['reply'] ?? '', isUser: json['is_user'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {"message": message, "news_id": newsId, "reply": reply};
  }
}
