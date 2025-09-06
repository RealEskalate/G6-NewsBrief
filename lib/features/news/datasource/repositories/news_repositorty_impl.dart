import 'package:newsbrief/features/news/datasource/datasources/news.local_data_sources.dart';
import 'package:newsbrief/features/news/datasource/datasources/news_remote_data_sources.dart';
import 'package:newsbrief/features/news/domain/entities/bookmark.dart';
import 'package:newsbrief/features/news/domain/entities/chat_message.dart';

import '../../domain/entities/news.dart';
import '../../domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSources remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<News>> getTrendingNews({int page = 1, int limit = 10}) async {
    try {
      final remoteNews = await remoteDataSource.getTrendingNews(
        page: page,
        limit: limit,
      );
      await localDataSource.cacheNews("trending_news", remoteNews);
      return remoteNews;
    } catch (_) {
      return localDataSource.getCachedNews("trending_news");
    }
  }

  @override
  Future<List<News>> getTodayNews() async {
    try {
      final remoteNews = await remoteDataSource.getTodayNews();
      await localDataSource.cacheNews("today_news", remoteNews);
      return remoteNews;
    } catch (_) {
      return localDataSource.getCachedNews("today_news");
    }
  }

  @override
  Future<List<News>> getForYouNews({int page = 1, int limit = 10}) async {
    try {
      final remoteNews = await remoteDataSource.getForYouNews(
        page: page,
        limit: limit,
      );
      await localDataSource.cacheNews("for_you_news", remoteNews);
      return remoteNews;
    } catch (_) {
      return localDataSource.getCachedNews("for_you_news");
    }
  }

  @override
  Future<List<News>> getNewsByTopic(
    String topicId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final remoteNews = await remoteDataSource.getNewsByTopic(
        topicId,
        page: page,
        limit: limit,
      );
      await localDataSource.cacheNews("topic_$topicId", remoteNews);
      return remoteNews;
    } catch (_) {
      return localDataSource.getCachedNews("topic_$topicId");
    }
  }

  @override
  Future<void> addBookmark(String newsId) =>
      remoteDataSource.addBookmark(newsId);

  @override
  Future<List<Bookmark>> getBookmarks() => remoteDataSource.getBookmarks();

  @override
  Future<void> removeBookmark(String newsId) =>
      remoteDataSource.removeBookmark(newsId);

  @override
  Future<ChatMessage> generalChat(String message) async {
    final chatMessageModel = await remoteDataSource.generalChat(
      message,
    );
    print(chatMessageModel);
    return ChatMessage(
      message: chatMessageModel.message,
      isUser: false,
      newsId: '',
    );
  }

  @override
  Future<ChatMessage> newsChat(String newsId, String message) async {
    final res = await remoteDataSource.newsChat(newsId, message);
    print(res);
    return ChatMessage(message: res.message, isUser: false, newsId: newsId);
  }
}
