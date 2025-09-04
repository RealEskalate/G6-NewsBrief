import 'package:flutter/material.dart';

class AppNavigator {
  // Push a new page with slide transition
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      slidePageRoute(page) as Route<T>,
    );
  }

  // Replace current page with slide transition
  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, T>(
      context,
      slidePageRoute(page) as Route<T>,
    );
  }

  // Remove all previous pages and push new page
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil(
      context,
      slidePageRoute(page) as Route<T>,
      (route) => false,
    );
  }

  // Central PageRouteBuilder with slide from right
  static PageRouteBuilder slidePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide in from right
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
