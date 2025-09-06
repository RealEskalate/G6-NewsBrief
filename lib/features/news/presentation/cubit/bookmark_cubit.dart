import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/news/domain/repositories/news_repository.dart';
import '../../domain/entities/bookmark.dart';


abstract class BookmarkState {}
class BookmarkInitial extends BookmarkState {}
class BookmarkLoading extends BookmarkState {}
class BookmarkLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  BookmarkLoaded(this.bookmarks);
}
class BookmarkError extends BookmarkState {
  final String message;
  BookmarkError(this.message);
}

class BookmarkCubit extends Cubit<BookmarkState> {
  final NewsRepository repository;

  BookmarkCubit(this.repository) : super(BookmarkInitial());

  Future<void> loadBookmarks() async {
    emit(BookmarkLoading());
    try {
      final bookmarks = await repository.getBookmarks();
      emit(BookmarkLoaded(bookmarks));
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> addBookmark(String newsId) async {
    try {
      await repository.addBookmark(newsId);
      loadBookmarks();
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }

  Future<void> removeBookmark(String newsId) async {
    try {
      await repository.removeBookmark(newsId);
      loadBookmarks();
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }
}
