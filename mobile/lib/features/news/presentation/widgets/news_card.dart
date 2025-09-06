import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';
import '../cubit/bookmark_cubit.dart';

class NewsCard extends StatefulWidget {
  final String id; // add id to identify news for bookmark
  final String topics;
  final String title;
  final String description;
  final String source;
  final String imageUrl;

  const NewsCard({
    super.key,
    required this.id,
    required this.topics,
    required this.title,
    required this.description,
    required this.source,
    required this.imageUrl,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  Future<void> _toggleSpeech(BuildContext context) async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() => isPlaying = false);
      return;
    }

    final langCode = context.locale.languageCode;
    String ttsLang = langCode == 'am' ? "am-ET" : "en-US";

    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak("${widget.title}. ${widget.description}");
    setState(() => isPlaying = true);

    flutterTts.setCompletionHandler(() {
      setState(() => isPlaying = false);
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Resolve source label from UserCubit state (match id/slug/name)
  String _resolveSourceLabel(UserState state) {
    final src = widget.source.toString();
    if (state is AllSourcesLoaded) {
      try {
        for (final s in state.sources.cast<Map<String, dynamic>>()) {
          final id = (s['id'] ?? 'EBC').toString();
          final slug = (s['slug'] ?? 'EBC').toString();
          final name = (s['name'] ?? 'EBC').toString();
          if (id == src || slug == src || name == src) {
            if (name.isNotEmpty) return name;
            if (slug.isNotEmpty) return slug;
          }
        }
      } catch (_) {}
    }
    return src.isNotEmpty ? src : 'EBC'.tr();
  }

  // Resolve topic label from UserCubit state (match id/slug/topic_name and prefer localized label)
  String _resolveTopicLabel(UserState state) {
    final t = widget.topics.toString();
    final locale = context.locale.languageCode;
    if (state is AllTopicsLoaded) {
      try {
        for (final tp in state.topics.cast<Map<String, dynamic>>()) {
          final id = (tp['id'] ?? 'General').toString();
          final slug = (tp['slug'] ?? 'General').toString();
          final topicName = (tp['topic_name'] ?? 'General').toString();
          if (id == t || slug == t || topicName == t) {
            // prefer localized label if available
            if (tp['label'] != null &&
                tp['label'][locale] != null &&
                tp['label'][locale].toString().isNotEmpty) {
              return tp['label'][locale].toString();
            }
            if (topicName.isNotEmpty) return topicName;
            if (slug.isNotEmpty) return slug;
          }
        }
      } catch (_) {}
    }
    return t.isNotEmpty ? t : 'General'.tr();
  }

  void _openDetail(BuildContext context) {
    final userState = context.read<UserCubit>().state;
    final sourceName = _resolveSourceLabel(userState);
    final topicName = _resolveTopicLabel(userState);

    Navigator.pushNamed(
      context,
      '/news_detail',
      arguments: {
        'id': widget.id,
        'topic': topicName,
        'title': widget.title,
        'source': sourceName,
        'imageUrl': widget.imageUrl,
        'detail': widget.description,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.imageUrl.isNotEmpty
                ? Image.network(
                    widget.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & Topic Row
                  Row(
                    children: [
                      BlocBuilder<UserCubit, UserState>(
                        builder: (context, state) {
                          final sourceLabel = _resolveSourceLabel(state);
                          return Flexible(
                            child: Text(
                              sourceLabel,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<UserCubit, UserState>(
                        builder: (context, state) {
                          final topicLabel = _resolveTopicLabel(state);
                          return Flexible(
                            child: Text(
                              topicLabel,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    widget.description.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Bookmark & TTS
                  BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, state) {
                      bool isBookmarked = false;
                      if (state is BookmarkLoaded) {
                        isBookmarked = state.bookmarks.any(
                          (b) => b.newsId == widget.id,
                        );
                      }

                      return Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: textColor,
                            ),
                            onPressed: () {
                              if (isBookmarked) {
                                context.read<BookmarkCubit>().removeBookmark(
                                  widget.id,
                                );
                              } else {
                                context.read<BookmarkCubit>().addBookmark(
                                  widget.id,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.stop : Icons.volume_up,
                              color: textColor,
                            ),
                            onPressed: () => _toggleSpeech(context),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
