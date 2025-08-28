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
    return ListTile(
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
