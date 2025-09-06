import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';
import '../cubit/bookmark_cubit.dart';
import 'news_detail_page.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ensures back arrow is shown
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/root'); // goes back
          },
        ),
        title: Text('saved'.tr()),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookmarkLoaded) {
            if (state.bookmarks.isEmpty) {
              return Center(child: Text('saved'.tr()));
            }
            return ListView.builder(
              itemCount: state.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = state.bookmarks[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(
                          id: bookmark.newsId,
                          topics: bookmark.topics[0],
                          title: bookmark.title,
                          source: bookmark.soureceId,
                          imageUrl:
                              'https://picsum.photos/200/300?random=$index',
                          detail: bookmark.body,
                        ),
                      ),
                    );
                  },
                  child: NewsCard(
                    id: bookmark.newsId,
                    topics: bookmark.topics[0],
                    title: bookmark.title,
                    description: bookmark.body,
                    source: bookmark.soureceId,
                    imageUrl: 'https://picsum.photos/200/300?random=$index',
                  ),
                );
              },
            );
          } else if (state is BookmarkError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: Text('welcome_saved'.tr()));
          }
        },
      ),
    );
  }
}
