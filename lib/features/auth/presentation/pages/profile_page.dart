import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/presentation/widgets/topic_chip.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top icons
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/root');
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/setting');
                    },
                    icon: const Icon(Icons.settings, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // User Name
              const Text(
                "John Doe",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // User Email
              const Text(
                "johndoe@example.com",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Indicators for Subscribed Sources & Saved News
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIndicator(
                    title: "Subscribed",
                    count: 12, // dummy data
                    color: Colors.blue.shade100,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageSubscriptionPage(),
                        ),
                      );
                    },
                  ),
                  _buildIndicator(
                    title: "Saved News",
                    count: 34, // dummy data
                    color: Colors.green.shade100,
                    onTap: () {
                      Navigator.pushNamed(context, '/saved');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 30),

              // "Your Interests" Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Interests",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 25,
                    runSpacing: 12,
                    children: topics
                        .map((topic) => TopicChip(title: topic))
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$count",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Manage Subscription Page
class ManageSubscriptionPage extends StatelessWidget {
  const ManageSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Subscriptions"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          "Here you can manage your subscriptions",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
