import 'package:flutter/material.dart';

class TopicChip extends StatelessWidget {
  final String title;
  final VoidCallback? onDeleted;

  const TopicChip({super.key, required this.title, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Chip(
      label: Text(
        title,
        style: TextStyle(color: colorScheme.onPrimary), // Text contrasts with bg
      ),
      backgroundColor: colorScheme.primary, // Use primary as background
      deleteIcon: onDeleted != null
          ? Icon(Icons.cancel, color: colorScheme.onPrimary, size: 18)
          : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.primary), // Border matches primary
      ),
      elevation: onDeleted != null ? 3 : 0,
      shadowColor: onDeleted != null ? colorScheme.primary.withOpacity(0.5) : null,
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
