import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/chat_cubit.dart';

// Chat message model
class ChatMessage {
  final String message;
  final bool isUser;
  final String newsId;

  ChatMessage({
    required this.message,
    this.isUser = false,
    required this.newsId,
  });
}

class ChatbotPopup extends StatefulWidget {
  final VoidCallback? onClose;

  const ChatbotPopup({super.key, this.onClose});

  @override
  State<ChatbotPopup> createState() => _ChatbotPopupState();
}

class _ChatbotPopupState extends State<ChatbotPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      message:
          "Hi there! I'm Tim, your News Brief Assistant. How can I help you today?",
      isUser: false,
      newsId: '',
    ),
  ];

  LinearGradient get assistantGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Colors.black],
  );

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(message: text, isUser: true, newsId: ''));
      _textController.clear();
    });

    _scrollToBottom();

    // Send message to ChatCubit
    context.read<ChatCubit>().sendGeneralMessage(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String parseMarkdownToText(String message) {
    // Remove common markdown symbols like **, *, _, #, etc.
    return message
        .replaceAll(RegExp(r'(\*\*|\*|__|_|`|#)'), '')
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1'); // [text](link) -> text
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey[600]!;

    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) {
          final chatMsg = state.message;
          print('chat: $chatMsg'); // This is a String
          setState(() {
            _messages.add(
              ChatMessage(
                message: parseMarkdownToText(chatMsg.toString()),
                isUser: false,
                newsId: '',
              ),
            );
          });
          _scrollToBottom();
        } else if (state is ChatError) {
          setState(() {
            _messages.add(
              ChatMessage(
                message: "Error: ${state.message}",
                isUser: false,
                newsId: '',
              ),
            );
          });
          _scrollToBottom();
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            height: 500,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: assistantGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'assistant'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: iconColor),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),

                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.isUser;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[400] : Colors.white,
                              gradient: isUser ? null : assistantGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: assistantGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'T',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (!isUser) const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    msg.message,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: isUser
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Input field
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: assistantGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: assistantGradient,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: 'ask_brief'.tr(),
                              hintStyle: const TextStyle(color: Colors.white70),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.mic, color: iconColor),
                                onPressed: () {},
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send, color: iconColor),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
