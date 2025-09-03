import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'saved'.tr(),
          style: textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: Text(
          'welcome_saved'.tr(),
          style: textTheme.bodyLarge,
        ),
      ),
    );
  }
}
