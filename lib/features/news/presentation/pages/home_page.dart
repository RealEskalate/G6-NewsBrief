import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';
import 'package:newsbrief/features/news/domain/entities/news.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_cubit.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_state.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/globe_background.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/bounce_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isChatbotVisible = false;
  bool _isLanguagePressed = false;
  bool _isNotificationPressed = false;
  bool _notificationsEnabled = false;

  late AnimationController _chatbotController;
  late Animation<Offset> _chatbotOffsetAnimation;
  late TabController _tabController;

  final LinearGradient activeGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Colors.black],
  );

  // Keep separate ScrollControllers for each tab
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();

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

    final userCubit = context.read<UserCubit>();
    final newsCubit = context.read<NewsCubit>();

    // Fetch "For You" news
    newsCubit.fetchForYouNews();

    // Fetch topic news if user already has topics
    if (userCubit.state is SubscribedTopicsLoaded) {
      final topics = (userCubit.state as SubscribedTopicsLoaded).topics;
      for (var topic in topics) {
        newsCubit.fetchNewsByTopic(topic['id']);
      }
    }
  }

  @override
  void dispose() {
    _chatbotController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
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
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Push Notifications".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.colorScheme.onBackground,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
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
                  setState(() => _notificationsEnabled = value);
                  _togglePushNotifications(value);
                },
              ),
            ],
          ),
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
      ),
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
    final isTablet = size.width > 600;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        List<Tab> tabs = [Tab(text: 'for_you'.tr())];
        List<String> tabTypes = ["for_you"];
        List<String?> topicIds = [null];

        if (userState is SubscribedTopicsLoaded) {
          for (var topic in userState.topics) {
            tabs.add(Tab(text: topic['label']['en'] ?? ''));
            tabTypes.add("topic");
            topicIds.add(topic['id']);
          }
        }

        _tabController = TabController(length: tabs.length, vsync: this);

        return Scaffold(
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

                      // --- Header ---
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: isTablet ? 48 : 36,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "NewsBrief",
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isLanguagePressed = true),
                            onTapUp: (_) =>
                                setState(() => _isLanguagePressed = false),
                            onTapCancel: () =>
                                setState(() => _isLanguagePressed = false),
                            onTap: () => _showLanguagePicker(context),
                            child: Row(
                              children: [
                                Text(
                                  context.locale.languageCode == 'en'
                                      ? 'EN'
                                      : 'አማ',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                _isLanguagePressed
                                    ? ShaderMask(
                                        shaderCallback: (bounds) =>
                                            activeGradient.createShader(bounds),
                                        child: const Icon(
                                          Icons.language_rounded,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.language_rounded,
                                        color: textColor,
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isNotificationPressed = true),
                            onTapUp: (_) =>
                                setState(() => _isNotificationPressed = false),
                            onTapCancel: () =>
                                setState(() => _isNotificationPressed = false),
                            onTap: () => _showPushNotificationsDialog(),
                            child: _isNotificationPressed
                                ? ShaderMask(
                                    shaderCallback: (bounds) =>
                                        activeGradient.createShader(bounds),
                                    child: const Icon(
                                      Icons.notifications_none,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.notifications_none,
                                    color: textColor,
                                  ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.02),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: textColor,
                        indicatorColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          fontSize: size.width > 600 ? 18 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: tabs,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: List.generate(tabs.length, (index) {
                            return _buildNewsList(
                              tabTypes[index],
                              topicIds[index],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Chatbot Popup ---
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
          floatingActionButton: _isChatbotVisible
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: activeGradient,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chat_outlined, color: Colors.white),
                    onPressed: _toggleChatbot,
                  ),
                )
              : BounceButton(
                  icon: Icons.chat_outlined,
                  onTap: _toggleChatbot,
                  isFab: true,
                  iconColor: theme.colorScheme.onPrimary,
                  backgroundColor: theme.colorScheme.primary,
                ),
        );
      },
    );
  }

  Widget _buildNewsList(String type, String? topicId) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        List<News> newsList = [];

        if (state is NewsLoaded) {
          if (type == "for_you") {
            newsList = state.news;
          } else if (type == "topic" && topicId != null) {
            newsList = state.news
                .where((news) => news.topics.contains(topicId))
                .toList();
          }
        } else if (state is NewsLoading || state is NewsInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NewsError) {
          return Center(child: Text("Failed to load news: ${state.message}"));
        }

        if (newsList.isEmpty) {
          return Center(child: Text("No news available".tr()));
        }

        final index = type == "for_you" ? 0 : topicId.hashCode;
        _scrollControllers[index] ??= ScrollController();

        return ListView.builder(
          controller: _scrollControllers[index],
          physics: const BouncingScrollPhysics(),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return NewsCard(
              id: news.id,
              topics: news.topics.isNotEmpty ? news.topics[0] : 'General',
              title: news.title,
              description: news.body,
              source: news.sourecId.isNotEmpty ? news.sourecId : 'EBC',
              imageUrl: "https://picsum.photos/200/300?random=$index",
            );
          },
        );
      },
    );
  }
}
