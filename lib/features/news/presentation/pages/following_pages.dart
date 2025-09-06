import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/core/widgets/topic_chip.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTopics = [];

  final ScrollController _scrollController = ScrollController();
  final ScrollController _chipScrollController = ScrollController();
  final ScrollController _sourcesScrollController = ScrollController();

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => setState(() {}));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _addTopic() {
    debugPrint("Add topic tapped");
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

  void _openNewsDetail(dynamic news) {
    String t = news.title;
    String s = news.source;
    String d = news.description;
    Navigator.pushNamed(
      context,
      '/news_detail',
      arguments: {
        'topic': 'for_you'.tr(),
        'title': t.tr(),
        'source': s.tr(),
        'imageUrl': news.imageUrl,
        'detail': d.tr(),
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chipScrollController.dispose();
    _sourcesScrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedChip(String topic, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = (_animationController.value - (index * 0.05)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(-50 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TopicChip(
          title: topic.tr(),
          onDeleted: _selectedTopics.contains(topic) ? () => _toggleTopic(topic) : null,
          // onTap: () => _toggleTopic(topic),
        ),
      ),
    );
  }

  Widget _buildAnimatedSource(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = (_animationController.value - (index * 0.05)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                "https://picsum.photos/200/200?random=20",
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Source $index",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                debugPrint("Subscribed to Source $index");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'subscribe'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'following_title'.tr(),
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Horizontal Topic Chips
              SizedBox(
                height: 46,
                child: Scrollbar(
                  controller: _chipScrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: ListView(
                    controller: _chipScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      GestureDetector(
                        onTap: _addTopic,
                        child: Chip(
                          avatar: Icon(Icons.add, color: colorScheme.onPrimary),
                          label: const Text(''),
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...topics.asMap().entries.map((entry) {
                        final index = entry.key;
                        final topic = entry.value;
                        return _buildAnimatedChip(topic, index);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 First 3 News Cards
              ...sampleNews.asMap().entries.map((entry) {
                final index = entry.key;
                final news = entry.value;
                final cardPosition = index * 250.0;
                final scrollOffset =
                    _scrollController.hasClients ? _scrollController.offset : 0;
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

              const SizedBox(height: 20),

              // 🔹 Sources horizontal section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'following_sources'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 160,
                child: Scrollbar(
                  controller: _sourcesScrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: ListView(
                    controller: _sourcesScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: List.generate(6, (index) {
                      return _buildAnimatedSource(index);
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 More News Cards
              ...sampleNews.asMap().entries.map((entry) {
                final index = entry.key + 3;
                final news = entry.value;
                final cardPosition = index * 250.0;
                final scrollOffset =
                    _scrollController.hasClients ? _scrollController.offset : 0;
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
            ],
          ),
        ),
      ),
    );
  }
}
