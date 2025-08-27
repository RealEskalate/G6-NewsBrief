import 'package:flutter/material.dart';

class TopicChip extends StatelessWidget {
  final String title;
  const TopicChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Sample topics list
  final List<String> topics = const [
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
    "Job Vaccany"
  ];