import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/core/widgets/topic_chip.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTopics = [];
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _topicScrollController = ScrollController();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _verticalScrollController.addListener(() => setState(() {}));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _openNewsDetail(NewsCardData news) {
    Navigator.pushNamed(
      context,
      '/news_detail',
      arguments: {
        'topic': 'for_you'.tr(),
        'title': news.title.tr(),
        'source': news.source.tr(),
        'imageUrl': news.imageUrl,
        'detail': news.description.tr(),
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    _topicScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text('search'.tr(), style: theme.textTheme.titleLarge),
      ),
      body: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Horizontal Topic Chips with slide + fade animation
              SizedBox(
                height: 46,
                child: Scrollbar(
                  controller: _topicScrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    controller: _topicScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return TweenAnimationBuilder(
                        tween: Tween<Offset>(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ),
                        duration: Duration(milliseconds: 300 + index * 100),
                        curve: Curves.easeOut,
                        builder: (context, Offset offset, child) {
                          return Transform.translate(
                            offset: offset * 50,
                            child: Opacity(
                              opacity: 1 - offset.dx.abs(),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: TopicChip(
                                  title: topic.tr(),
                                  onDeleted: _selectedTopics.contains(topic)
                                      ? () => _toggleTopic(topic)
                                      : null,
                                  // onTap: () => _toggleTopic(topic),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Trending News Label
              Text(
                'trending_news'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Vertical Animated News Cards
              Column(
                children: sampleNews.asMap().entries.map((entry) {
                  final index = entry.key;
                  final news = entry.value;
                  final cardPosition = index * 250.0;
                  final scrollOffset = _verticalScrollController.hasClients
                      ? _verticalScrollController.offset
                      : 0.0;
                  final isVisible = scrollOffset + 600 > cardPosition;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: isVisible ? 1.0 : 0.0,
                    child: Transform.translate(
                      offset: Offset(0, isVisible ? 0 : 30),
                      child: GestureDetector(
                        onTap: () => _openNewsDetail(news),
                        child: NewsCard(
                          title: news.title,
                          description: news.description,
                          source: news.source,
                          imageUrl: news.imageUrl,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
