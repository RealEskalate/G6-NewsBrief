
import 'package:flutter/material.dart';

class TopicChip extends StatelessWidget {
  final String title;
  final VoidCallback? onDeleted;

  const TopicChip({
    super.key,
    required this.title,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      deleteIcon: onDeleted != null ? const Icon(Icons.cancel, color: Colors.white, size: 18) : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black),
      ),
      elevation: onDeleted != null ? 3 : 0, // Adds a subtle shadow when deleting
      shadowColor: onDeleted != null ? Colors.black54 : null, // The color of the shadow
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
    "Job Vacancy"
  ];