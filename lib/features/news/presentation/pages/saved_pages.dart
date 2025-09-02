import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: Text(
          "Welcome to saved 🎉",
          style: textTheme.bodyLarge,
        ),
      ),
    );
  }
}
