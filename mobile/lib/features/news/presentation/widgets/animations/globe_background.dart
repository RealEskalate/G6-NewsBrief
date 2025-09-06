import 'package:flutter/material.dart';
import 'dart:math';

class GlobeBackground extends StatefulWidget {
  const GlobeBackground({super.key});

  @override
  State<GlobeBackground> createState() => _GlobeBackgroundState();
}

class _GlobeBackgroundState extends State<GlobeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // slow rotation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [
            // 🔹 Main rotating globe
            Center(
              child: Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/globe.png',
                    width: screenSize.width * 0.95,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 🔹 Top-right mini globe
            Positioned(
              top: 20,
              right: 85,
              child: Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/globe.png',
                    width: screenSize.width * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 🔹 Bottom-left mini globe
            Positioned(
              bottom: 20,
              left: 20,
              child: Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/globe.png',
                    width: screenSize.width * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
