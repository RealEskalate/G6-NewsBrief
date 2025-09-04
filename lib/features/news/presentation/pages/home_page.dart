import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/globe_background.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';

import 'package:newsbrief/features/news/presentation/widgets/animations/bounce_button.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChatbotVisible = false;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  void _toggleChatbot() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
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
    final textColor = theme.colorScheme.onBackground;
    final background = theme.colorScheme.background;

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: background,
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
                          fontSize: isTablet ? 36 : 28,
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
                      BounceButton(
                        icon: Icons.notifications_none,
                        onTap: () {},
                        iconColor: textColor,
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  // 🔹 Section Title
                  Text(
                    'for_you'.tr(),
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // 🔹 Animated News List
                  Expanded(
                    child: ListView.builder(
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
                              ),
                            ),
                          ),
                        );
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
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.6,
                  ),
                  child: ChatbotPopup(onClose: _toggleChatbot),
                ),
              ),
            ),
        ],
      ),

      // 🔹 FAB with BounceButton
      floatingActionButton: BounceButton(
        icon: Icons.chat_outlined,
        onTap: _toggleChatbot,
        isFab: true,
        iconColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
