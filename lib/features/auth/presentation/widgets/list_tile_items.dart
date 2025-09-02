import 'package:flutter/material.dart';

class ListTileItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const ListTileItem({
    super.key,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final iconColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: iconColor,
          ),
      onTap: onTap,
    );
  }
}
