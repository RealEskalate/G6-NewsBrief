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
  final Set<String> subscribedSources = {"CNN", "Fana"}; // Dummy initial state
  final TextEditingController searchController = TextEditingController();

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
        ),
        title: Text(
          "Manage Subscriptions",
          style: TextStyle(
            color: theme.colorScheme.onBackground,
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
                hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              style: TextStyle(color: theme.colorScheme.onBackground),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSources.length,
              itemBuilder: (context, index) {
                final source = filteredSources[index];
                final isSubscribed = subscribedSources.contains(source);
                return ListTile(
                  title: Text(source, style: TextStyle(color: theme.colorScheme.onBackground)),
                  trailing: ElevatedButton(
                    onPressed: () => _toggleSubscription(source),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: isSubscribed
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onBackground,
                      backgroundColor: isSubscribed
                          ? theme.colorScheme.primary
                          : theme.scaffoldBackgroundColor,
                      side: BorderSide(color: theme.colorScheme.onBackground, width: 1),
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
