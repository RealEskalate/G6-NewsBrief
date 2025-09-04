import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/globe_background.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/bounce_button.dart';
import 'package:newsbrief/features/news/presentation/widgets/animations/bubble_background.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔹 Bubble background widget (directly)
          const GlobeBackground(),

          // 🔹 Foreground UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "NewsBrief",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      BounceButton(
                        icon: Icons.language_rounded,
                        iconColor: Colors.black, 
                        onTap: () {},
                      ),
                      BounceButton(
                        icon: Icons.notifications_none, 
                        onTap: () {},
                        iconColor: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "For You",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: sampleNews.length,
                      itemBuilder: (context, index) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click, // pointer cursor only on news
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
                            child: NewsCard(
                              title: sampleNews[index].title,
                              description: sampleNews[index].description,
                              source: sampleNews[index].source,
                              imageUrl: sampleNews[index].imageUrl,
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
              child: ChatbotPopup(
                onClose: _toggleChatbot,
              ),
            ),
        ],
      ),
      floatingActionButton: BounceButton(
        icon: Icons.chat_outlined,
        onTap: _toggleChatbot,
        isFab: true,
        iconColor: Colors.black,
      ),
    );
  }
}
