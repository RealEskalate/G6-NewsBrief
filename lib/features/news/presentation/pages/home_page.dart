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
  bool _isLanguagePressed = false;
  bool _isNotificationPressed = false;
  bool _notificationsEnabled = false;

  late ScrollController _scrollController;
  double _scrollOffset = 0;

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

    final isTablet = size.width > 600;

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
                        Image.asset(
                          'assets/images/logo.png',
                          height: isTablet ? 48 : 36,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "NewsBrief", // or 'app_name'.tr()
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // trims text if too long
                            maxLines: 1,
                          ),
                        ),
                        // const Spacer(),
                        // Language Icon with label
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
                              // Label based on current language
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

                        // Notification Icon
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        isScrollable: true,
                        labelColor: textColor,
                        indicatorColor: theme.colorScheme.primary,
                        tabAlignment: TabAlignment
                            .center, // <-- makes tabs align left (Flutter 3.7+)
                        labelStyle: TextStyle(
                          fontSize: size.width > 600 ? 18 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: 'for_you'.tr()),
                          Tab(text: 'trending'.tr()),
                          Tab(text: 'today'.tr()),
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
        // FAB
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
               return NewsCard(
                  id: news.id,
                  topics: news.topics.isNotEmpty ? news.topics[0] : 'General',
                  title: news.title,
                  description: news.body,
                  source: news.soureceId.isNotEmpty ? news.soureceId : 'EBC',
                  imageUrl: "https://picsum.photos/200/300?random=$index"
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
