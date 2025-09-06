

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/core/widgets/topic_chip.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_cubit.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_state.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';
// import 'package:newsbrief/features/auth/presentation/cubit/user_state.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Load topics, sources, and initial news
    context.read<UserCubit>().loadSubscribedTopics();
    context.read<UserCubit>().loadAllSources();
    context.read<NewsCubit>().fetchTodayNews();
    context.read<NewsCubit>().fetchTrendingNews();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _showAddTopicDialog() {
    final theme = Theme.of(context);

    // Ask the cubit to load all topics (if not already loaded)
    context.read<UserCubit>().loadAllTopics();

    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AllTopicsLoaded) {
              final topics = state.topics;
              // print(topics); // this should be List<Map<String, dynamic>>
              return AlertDialog(
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Text(
                  "add_new_topic".tr(),
                  style: TextStyle(color: theme.colorScheme.onBackground),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      print(topic);
                      final label = topic['label']['en'];
                      return ListTile(
                        title: Text(
                          label,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        onTap: () {
                          // Subscribe with the topic's ID
                          context.read<UserCubit>().subscribe([topic['id']]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "cancel".tr(),
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is UserError) {
              return AlertDialog(
                title: Text("error".tr()),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("ok".tr()),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  void _openNewsDetail(dynamic news) {
    Navigator.pushNamed(
      context,
      '/news_detail',
      arguments: {
        'topic': news.topics[0] ?? 'for_you'.tr(), // use topic if available
        'title': news.title,
        'source':
            news.soureceId?? '', // use available source field
        'imageUrl': 'https://picsum.photos/200/300?random=${1}', // default empty if no image
        'detail': news.body ?? news.description ?? '', // full news text
      },
    );
  }

  // void _toggleSubscription(String slug) {
  //   final userCubit = context.read<UserCubit>();
  //   if (subscribedSources.contains(slug)) {
  //     userCubit.removeSources(slug); // unsubscribe
  //   } else {
  //     userCubit.addSources(slug); // subscribe
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Topics Row (UserCubit)
              // 🔹 Topics Row
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is SubscribedTopicsLoaded) {
                    final topics = state.topics;
                    print('topics count: ${topics.length}');

                    return SizedBox(
                      height: 56, // Enough height for chips
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount:
                            topics.length + 1, // +1 for "Add Topic" button
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // First item: Add Topic button
                            return GestureDetector(
                              onTap: _showAddTopicDialog,
                              child: Chip(
                                avatar: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: const SizedBox.shrink(),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }

                          final topic = topics[index - 1];
                          final label = topic['label']['en'];
                          print('label$label');
                          return TopicChip(
                            title: label,
                            onTap: () {
                              context.read<NewsCubit>().fetchNewsByTopic(
                                topic['id'],
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

              // 🔹 Today’s News (NewsCubit)
              BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoaded) {
                    return Column(
                      children: state.news
                          .map(
                            (news) => GestureDetector(
                              onTap: () => _openNewsDetail(news),
                              child: NewsCard(
                                topics: news.topics.isNotEmpty ? news.topics[0] : '',
                                title: news.title,
                                description: news.body,
                                source: news.soureceId,
                                imageUrl: '',
                              ),
                            ),
                          )
                          .toList(),
                    );
                  } else if (state is NewsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Sources Row (UserCubit)
              Text(
                'following_sources'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is AllSourcesLoaded) {
                    return SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.sources.length,
                        itemBuilder: (context, index) {
                          final source = state.sources[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
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
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(
                                    source["logoUrl"] ??
                                        "https://picsum.photos/200",
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(source["name"]),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<UserCubit>().addSources(
                                      source["slug"],
                                    );
                                  },
                                  
                                  child: Text(
                                    'subscribe'.tr(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Trending News
              Text(
                "Trending",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoaded) {
                    return Column(
                      children: state.news
                          .map(
                            (news) => GestureDetector(
                              onTap: () => _openNewsDetail(news),
                              child: NewsCard(
                                topics: news.topics.isNotEmpty ? news.topics[0] : '',
                                title: news.title,
                                description: news.body,
                                source: news.soureceId,
                                imageUrl:
                                    'https://picsum.photos/200/300?random=${1}',
                              ),
                            ),
                          )
                          .toList(),
                    );
                  } else if (state is NewsLoading) {
                    return const Center(child: CircularProgressIndicator());
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
