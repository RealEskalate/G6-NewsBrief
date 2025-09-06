import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_state.dart';



class NewsCubit extends Cubit<NewsState>{
  final NewsRepository repository;
  NewsCubit(this.repository) : super(NewsInitial());

  Future<void> fetchTrendingNews({int page = 1, int limit = 10}) async {
    emit(NewsLoading());
    try {
      final news = await repository.getTrendingNews(page: page, limit: limit);
      emit(NewsLoaded(news));
    } catch (e) {
      emit(NewsError("Failed to fetch trending news"));
    }
  }

  Future<void> fetchTodayNews() async {
    emit(NewsLoading());
    try {
      final news = await repository.getTodayNews();
      emit(NewsLoaded(news));
    } catch (e) {
      emit(NewsError("Failed to fetch today's news"));
    }
  }

  Future<void> fetchForYouNews({int page = 1, int limit = 10}) async {
    emit(NewsLoading());
    try {
      final news = await repository.getForYouNews(page: page, limit: limit);
      emit(NewsLoaded(news));
    } catch (e) {
      emit(NewsError("Failed to fetch personalized news"));
    }
  }

  Future<void> fetchNewsByTopic(String topicId, {int page = 1, int limit = 10}) async {
    emit(NewsLoading());
    try {
      final news = await repository.getNewsByTopic(topicId, page: page, limit: limit);
      emit(NewsLoaded(news));
    } catch (e) {
      emit(NewsError("Failed to fetch news for topic $topicId"));
    }
  }
}