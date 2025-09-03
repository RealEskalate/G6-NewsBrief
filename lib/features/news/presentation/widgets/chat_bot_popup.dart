import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surface;
    final headerBackground = theme.colorScheme.background;
    final textColor = theme.colorScheme.onBackground;
    final iconColor = theme.colorScheme.onBackground;

    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          height: 500,
          width: 350,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: headerBackground,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'assistant'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),

              // Chat messages placeholder
              Expanded(
                child: Center(
                  child: Text(
                    'chat_placeholder'.tr(),
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),

              // Input field + buttons
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: headerBackground,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ask_brief'.tr(),
                          hintStyle:
                          TextStyle(color: textColor.withOpacity(0.6)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: iconColor),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.mic, color: iconColor),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
