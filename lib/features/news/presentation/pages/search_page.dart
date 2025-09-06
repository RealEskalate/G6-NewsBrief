import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/core/widgets/topic_chip.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_cubit.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_state.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';
// import 'package:newsbrief/features/auth/presentation/cubit/user_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
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

    // Load topics & trending news at startup
    context.read<UserCubit>().loadAllTopics();
    context.read<NewsCubit>().fetchTrendingNews();
  }

  void _openNewsDetail(dynamic news) {
    Navigator.pushNamed(
      context,
      '/news_detail',
      arguments: {
        'topic': news.topics[0] ?? 'trending'.tr(),
        'title': news.title,
        'source': news.soureceId,
        'imageUrl': 'https://picsum.photos/200/300?random=${1}',
        'detail': news.body,
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

              // 🔹 Animated Horizontal Topic Chips
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is AllTopicsLoaded) {
                    final topics = state.topics;

                    return SizedBox(
                      height: 46,
                      child: ListView.separated(
                        controller: _topicScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: topics.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          final label = topic['label']['en'];

                          return TweenAnimationBuilder<Offset>(
                            tween: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ),
                            duration: Duration(milliseconds: 300 + index * 100),
                            curve: Curves.easeOut,
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: offset * 50,
                                child: Opacity(
                                  opacity: 1 - offset.dx.abs(),
                                  child: TopicChip(
                                    title: label,
                                    onTap: () {
                                      context
                                          .read<NewsCubit>()
                                          .fetchNewsByTopic(topic['id']);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const SizedBox.shrink();
                  }
                },
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

              // 🔹 Trending News Cards
              BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoaded) {
                    return Column(
                      children: state.news
                          .asMap()
                          .entries
                          .map((entry) {
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
                                    topics: news.topics[0],
                                    title: news.title,
                                    description: news.body,
                                    source: news.soureceId,
                                    imageUrl: 'https://picsum.photos/200/300?random=$index',
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    );
                  } else if (state is NewsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NewsError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
