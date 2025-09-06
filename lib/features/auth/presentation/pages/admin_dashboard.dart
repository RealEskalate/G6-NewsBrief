import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'sources_page.dart'; // New API-integrated SourcesPage
import 'topics_page.dart';  // New API-integrated TopicsPage
import 'news_page.dart';
import 'admin_settings_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Updated pages with new API-integrated versions
  final List<Widget> _pages = [
    const DashboardPage(),
    const SourcesPage(), // Use API-integrated SourcesPage
    const TopicsPage(),  // Use API-integrated TopicsPage
    const AddNewsPage(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Sources",
    "Topics",
    "News",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.dashboard,
                color: _selectedIndex == 0 ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.source,
                color: _selectedIndex == 1 ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: Icon(
                Icons.topic,
                color: _selectedIndex == 2 ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(
                Icons.article,
                color: _selectedIndex == 3 ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => _onItemTapped(3),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminSettingsPage()),
                );
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFF2563EB),
                child: const Text(
                  "A",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
