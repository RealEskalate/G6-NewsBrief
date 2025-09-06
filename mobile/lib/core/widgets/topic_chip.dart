import 'package:flutter/material.dart';

class TopicChip extends StatelessWidget {
  final String title;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;

  const TopicChip({
    super.key,
    required this.title,
    this.onDeleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        label: Text(
          title,
          style: TextStyle(
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        deleteIcon: onDeleted != null
            ? Icon(Icons.cancel, color: colorScheme.onPrimary, size: 18)
            : null,
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.primary),
        ),
        elevation: onDeleted != null ? 3 : 0,
        shadowColor:
            onDeleted != null ? colorScheme.primary.withOpacity(0.5) : null,
      ),
    );
  }
}


List<String> topics = [
  "Technology",
  "Sports",
  "Business",
  "Entertainment",
  "Health",
  "Politics",
  "Science",
  "Travel",
  "Fashion",
  "Food",
  "AI",
  "Job Vacancy",
];
