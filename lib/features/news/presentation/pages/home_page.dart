import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChatbotVisible = false;

  void _toggleChatbot() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
    });
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.04), // adaptive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "NewsBrief",
                        style: TextStyle(
                          fontSize: isTablet ? 36 : 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.language_rounded,
                          color: textColor,
                          size: isTablet ? 30 : 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none,
                          color: textColor,
                          size: isTablet ? 30 : 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),
                  Text(
                    "For You",
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sampleNews.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: NewsCard(
                            title: sampleNews[index].title,
                            description: sampleNews[index].description,
                            source: sampleNews[index].source,
                            imageUrl: sampleNews[index].imageUrl,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chatbot Popup
          if (_isChatbotVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.6, // prevent overflow
                  ),
                  child: ChatbotPopup(onClose: _toggleChatbot),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleChatbot,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: Icon(
          Icons.chat_outlined,
          size: isTablet ? 28 : 22,
        ),
      ),
    );
  }
}
