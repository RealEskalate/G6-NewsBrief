import 'package:flutter/material.dart';

class IndicatorCard extends StatefulWidget {
  final String title;
  final int count;
  final VoidCallback onTap;
  final Color? color; // optional color

  const IndicatorCard({
    super.key,
    required this.title,
    required this.count,
    required this.onTap,
    this.color,
  });

  @override
  State<IndicatorCard> createState() => _IndicatorCardState();
}

class _IndicatorCardState extends State<IndicatorCard> {
  bool _isPressed = false;
  final Duration animationDuration = const Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
    theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final secondaryTextColor =
    theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    // Professional adaptive color if none is provided
    final cardColor = widget.color ??
        (theme.brightness == Brightness.dark
            ? Colors.blueGrey.shade800
            : Colors.blueGrey.shade100);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: animationDuration,
        curve: Curves.easeInOut,
        child: Container(
          width: 150,
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.count}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
