import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'following_title'.tr(),
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: Center(
        child: Text(
          'following_welcome'.tr(),
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
