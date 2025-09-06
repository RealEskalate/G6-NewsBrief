import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';
import '../cubit/bookmark_cubit.dart';

class NewsCard extends StatefulWidget {
  final String id;
  final String topicId;
  final String title;
  final String description;
  final String sourceId;
  final String imageUrl;

  const NewsCard({
    super.key,
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.sourceId,
    required this.imageUrl,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  Future<void> _toggleSpeech() async {
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

  String _getSourceName(UserLoaded state) {
    final match = state.sources.firstWhere(
      (s) => s['id'].toString() == widget.sourceId,
      orElse: () => {'name': '', 'slug': ''},
    );
    return (match['name']?.toString().isNotEmpty == true)
        ? match['name']
        : (match['slug']?.toString().isNotEmpty == true ? match['slug'] : widget.sourceId);
  }

  String _getTopicName(UserLoaded state) {
    final match = state.topics.firstWhere(
      (t) => t['id'].toString() == widget.topicId,
      orElse: () => {'name': '', 'slug': ''},
    );
    return (match['name']?.toString().isNotEmpty == true)
        ? match['name']
        : (match['slug']?.toString().isNotEmpty == true ? match['slug'] : widget.topicId);
  }

  void _openDetail(BuildContext context, String sourceName, String topicName) {
    Navigator.pushNamed(
      context,
      '/news_detail',
      arguments: {
        'id': widget.id,
        'topic': topicName.isNotEmpty ? topicName : 'for_you'.tr(),
        'title': widget.title,
        'source': sourceName,
        'imageUrl': widget.imageUrl,
        'detail': widget.description,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String sourceName = widget.sourceId;
        String topicName = widget.topicId;

        if (state is UserLoaded) {
          sourceName = _getSourceName(state);
          topicName = _getTopicName(state);
        }

        return GestureDetector(
          onTap: () => _openDetail(context, sourceName, topicName),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
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
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source & Topic Row
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              sourceName,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              topicName,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        widget.description.tr(),
                        style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Bookmark & TTS
                      BlocBuilder<BookmarkCubit, BookmarkState>(
                        builder: (context, bookmarkState) {
                          final isBookmarked = bookmarkState is BookmarkLoaded
                              ? bookmarkState.bookmarks.any((b) => b.newsId == widget.id)
                              : false;

                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: textColor),
                                onPressed: () {
                                  if (isBookmarked) {
                                    context.read<BookmarkCubit>().removeBookmark(widget.id);
                                  } else {
                                    context.read<BookmarkCubit>().addBookmark(widget.id);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(isPlaying ? Icons.stop : Icons.volume_up, color: textColor),
                                onPressed: _toggleSpeech,
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
      },
    );
  }
}
