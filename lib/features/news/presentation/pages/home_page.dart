import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/globe_background.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/bounce_button.dart';
import 'package:easy_localization/easy_localization.dart';

import 'saved_pages.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final background = theme.colorScheme.background;

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: background,
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
                        Text(
                          "NewsBrief",
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),

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
                                  : Icon(Icons.language_rounded, color: textColor),
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
                          onTap: () {},
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

                    // TabBar
                    TabBar(
                      labelColor: textColor,
                      indicatorColor: theme.colorScheme.primary,
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'for_you'.tr()),
                        Tab(text: 'trending'.tr()),
                        Tab(text: 'subscribed'.tr()),
                        Tab(text: 'offline'.tr()),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    // TabBarView with scrolling animations
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

  // News list builder with scrolling animations
  Widget _buildNewsList(Size size) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: sampleNews.length,
      itemBuilder: (context, index) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 600 + (index * 120)),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.02),
              child: NewsCard(
                title: sampleNews[index].title,
                description: sampleNews[index].description,
                source: sampleNews[index].source,
                imageUrl: sampleNews[index].imageUrl,
                onBookmark: widget.onBookmarkTap,
              ),
            ),
          ),
        );
      },
    );
  }
}
