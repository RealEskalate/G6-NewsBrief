import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/presentation/widgets/chat_bot_popup.dart';
import 'package:newsbrief/features/news/presentation/widgets/news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. State variable to control chatbot visibility
  bool _isChatbotVisible = false;

  void _toggleChatbot() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    body: Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "NewsBrief",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(200, 0, 0, 0),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                    onPressed: () {
                      
                    },
                    icon: const Icon(Icons.language_rounded, color: Colors.black),
                  ),
                    
                    IconButton(
                    onPressed: () {
                      
                    },
                    icon: const Icon(Icons.notifications_none, color: Colors.black),
                  ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "For You",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(200, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: sampleNews.length,
                    itemBuilder: (BuildContext context, int index) {
                      return NewsCard(
                        title: sampleNews[index].title,
                        description: sampleNews[index].description,
                        source: sampleNews[index].source,
                        imageUrl: sampleNews[index].imageUrl,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ Chatbot overlay
        if (_isChatbotVisible)
          Align(
            alignment: Alignment.bottomCenter,
            child: ChatbotPopup(
              onClose: _toggleChatbot,
            ),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _toggleChatbot,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      foregroundColor: Colors.white,
      child: const Icon(Icons.chat_outlined),
    ),
  );
  }
}
