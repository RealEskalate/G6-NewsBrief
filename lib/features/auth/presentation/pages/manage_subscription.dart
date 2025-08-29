// lib/features/auth/presentation/pages/manage_subscription_page.dart

import 'package:flutter/material.dart';

class ManageSubscriptionPage extends StatefulWidget {
  const ManageSubscriptionPage({super.key});

  @override
  State<ManageSubscriptionPage> createState() => _ManageSubscriptionPageState();
}

class _ManageSubscriptionPageState extends State<ManageSubscriptionPage> {
  final List<String> allSources = [
    "CNN",
    "Addis Standard",
    "Fana",
    "BBC Amharic",
    "Reuters",
    "Al Jazeera",
    "The Guardian",
    "Associated Press",
  ];

  late List<String> filteredSources;
  final Set<String> subscribedSources = {"CNN", "Fana"}; // Dummy data for initial state
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSources = allSources;
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredSources = allSources
          .where((source) =>
              source.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSubscription(String source) {
    setState(() {
      if (subscribedSources.contains(source)) {
        subscribedSources.remove(source);
      } else {
        subscribedSources.add(source);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Manage Subscriptions",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search for sources...",
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSources.length,
              itemBuilder: (context, index) {
                final source = filteredSources[index];
                final isSubscribed = subscribedSources.contains(source);
                return ListTile(
                  title: Text(source, style: const TextStyle(color: Colors.black)),
                  trailing: ElevatedButton(
                    onPressed: () => _toggleSubscription(source),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: isSubscribed ? Colors.white : Colors.black,
                      backgroundColor: isSubscribed ? Colors.black : Colors.white,
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(isSubscribed ? "Subscribed" : "Subscribe"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}