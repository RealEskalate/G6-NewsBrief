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
  final VoidCallback? onBookmarkTap;

  const HomePage({super.key, this.onBookmarkTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isChatbotVisible = false;
  bool _notificationsEnabled = false;
  double _scrollOffset = 0.0;
  late ScrollController _scrollController;

  late final AnimationController _chatbotController;
  late final Animation<Offset> _chatbotOffsetAnimation;

  final LinearGradient activeGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Colors.black],
  );

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset * 0.2;
        });
      });

    _chatbotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _chatbotOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _chatbotController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatbotController.dispose();
    super.dispose();
  }

  void _toggleChatbot() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
      if (_isChatbotVisible) {
        _chatbotController.forward();
      } else {
        _chatbotController.reverse();
      }
    });
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('select_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('english'.tr()),
              onTap: () async {
                await context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('amharic'.tr()),
              onTap: () async {
                await context.setLocale(const Locale('am'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPushNotificationsDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Push Notifications".tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onBackground,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Do you want to enable push notifications?".tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Enable Notifications".tr(),
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _togglePushNotifications(value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close".tr(),
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePushNotifications(bool enable) {
    print(
      enable
          ? "Push notifications enabled.".tr()
          : "Push notifications disabled.".tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textColor = theme.colorScheme.onBackground;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Stack(
          children: [
            const GlobeBackground(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.01),

                    // Header
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
                          onTap: () => _showLanguagePicker(context),
                        ),
                        SizedBox(width: size.width * 0.02),
                        BounceButton(
                          icon: Icons.notifications_none,
                          onTap: () => _showPushNotificationsDialog(),
                          iconColor: textColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fix: Remove trailing space
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        labelColor: textColor,
                        indicatorColor: theme.colorScheme.primary,
                        tabAlignment: TabAlignment.center, // <-- makes tabs align left (Flutter 3.7+)
                        labelStyle: TextStyle(
                          fontSize: size.width > 600 ? 18 : 14,fontWeight: FontWeight.bold),
                        tabs: [
                          
                          Tab(text: 'for_you'.tr()),
                          Tab(text: 'trending'.tr()),
                          Tab(text: 'subscribed'.tr()),
                          Tab(text: 'offline'.tr()),
                          
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildNewsList(size),
                          _buildNewsList(size),
                          _buildNewsList(size),
                          _buildNewsList(size),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chatbot Popup
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _chatbotOffsetAnimation,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: size.height * 0.6),
                    child: ChatbotPopup(onClose: _toggleChatbot),
                  ),
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
      ),
    );
  }

  // Build news list with Bloc integration
  Widget _buildNewsList(Size size) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator());
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
                      'imageUrl': "https://picsum.photos/200/300?random=$index",
                      'detail': news.body,
                    },
                  );
                },
                child: NewsCard(
                  topics: news.topics.isNotEmpty ? news.topics[0] : '',
                  title: news.title,
                  description: news.body,
                  source: news.soureceId,
                  imageUrl: "https://picsum.photos/200/300?random=$index",
                  onBookmark: widget.onBookmarkTap,
                ),
              );
            },
          );
        } else if (state is NewsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
