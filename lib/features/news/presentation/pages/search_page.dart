import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'search'.tr(),
          style: textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: Text(
          'welcome_search'.tr(),
          style: textTheme.bodyLarge,
        ),
      ),
    );
  }
}
