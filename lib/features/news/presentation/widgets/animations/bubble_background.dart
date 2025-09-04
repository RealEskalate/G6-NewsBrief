import 'dart:math';
import 'package:flutter/material.dart';

class BubbleBackground extends StatefulWidget {
  const BubbleBackground({super.key});

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 25), // slow & smooth
      vsync: this,
    )..repeat();

    // Generate bubbles only once
    for (int i = 0; i < 20; i++) {
      _bubbles.add(
        _Bubble(
          dx: _random.nextDouble(),
          dy: _random.nextDouble(),
          size: 10.0 + _random.nextDouble() * 20.0,
          speed: 0.2 + _random.nextDouble() * 0.3, // slow speed
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BubblePainter(
            bubbles: _bubbles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Bubble {
  double dx;
  double dy;
  double size;
  double speed;

  _Bubble({
    required this.dx,
    required this.dy,
    required this.size,
    required this.speed,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double progress;

  _BubblePainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.2);

    for (var bubble in bubbles) {
      final double x = bubble.dx * size.width;
      final double y =
          (bubble.dy * size.height) - (progress * size.height * bubble.speed);

      final double wrappedY = y % size.height; // loop animation smoothly

      canvas.drawCircle(Offset(x, wrappedY), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
