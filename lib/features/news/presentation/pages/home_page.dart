import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_cubit.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_state.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/globe_background.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';

import 'package:newsbrief/features/news/presentation/widgets/animations/bounce_button.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePage> {
  bool _isChatbotVisible = false;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  void _toggleChatbot() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset * 0.2;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textColor = theme.colorScheme.onBackground;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          const GlobeBackground(),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header
                  Row(
                    children: [
                      Text(
                        'app_name'.tr(),
                        style: TextStyle(
                          fontSize: size.width > 600 ? 36 : 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      BounceButton(
                        icon: Icons.language_rounded,
                        iconColor: textColor,
                        onTap: () {}, // language picker
                      ),
                      BounceButton(
                        icon: Icons.notifications_none,
                        onTap: () {},
                        iconColor: textColor,
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  Text(
                    'for_you'.tr(),
                    style: TextStyle(
                      fontSize: size.width > 600 ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // 🔹 BlocBuilder for News
                  Expanded(
                    child: BlocBuilder<NewsCubit, NewsState>(
                      builder: (context, state) {
                        if (state is NewsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is NewsLoaded) {
                          final newsList = state.news;
                          return ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: newsList.length,
                            itemBuilder: (context, index) {
                              final news = newsList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/news_detail',
                                    arguments: {
                                      'topic': news.topics.isNotEmpty
                                          ? news.topics[0]
                                          : 'for_you'.tr(),
                                      'title': news.title,
                                      'source': news.soureceId,
                                      'imageUrl':
                                          "https://picsum.photos/200/300?random=$index",
                                      'detail': news.body,
                                    },
                                  );
                                },
                                child: NewsCard(
                                  topics: news.topics[0],
                                  title: news.title,
                                  description: news.body,
                                  source: news.soureceId,
                                  imageUrl:
                                      "https://picsum.photos/200/300?random=$index",
                                  onBookmark: () {
                                    // context.read<NewsCubit>().bookmark(news);
                                  },
                                ),
                              );
                            },
                          );
                        } else if (state is NewsError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Chatbot popup
          if (_isChatbotVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: size.height * 0.6),
                  child: ChatbotPopup(onClose: _toggleChatbot),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: BounceButton(
        icon: Icons.chat_outlined,
        onTap: _toggleChatbot,
        isFab: true,
        iconColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
