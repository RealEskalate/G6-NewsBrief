import 'package:flutter/material.dart';

class BounceButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isFab;
  final Color? iconColor;       // optional
  final Color? backgroundColor; // optional

  const BounceButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isFab = false,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _controller,
        child: widget.isFab
            ? FloatingActionButton(
                onPressed: widget.onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: widget.backgroundColor ?? Colors.orange,
                foregroundColor: widget.iconColor ?? Colors.white,
                child: Icon(widget.icon),
              )
            : Icon(
                widget.icon,
                color: widget.iconColor ?? Colors.black, // use passed color
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
