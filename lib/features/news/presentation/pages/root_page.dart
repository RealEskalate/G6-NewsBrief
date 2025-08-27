import 'package:flutter/material.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_page.dart';
import 'package:newsbrief/features/news/presentation/pages/following_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/home_page.dart';
import 'package:newsbrief/features/news/presentation/pages/saved_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/search_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: IndexedStack(
        index: currentPage,
        children: const [
          HomePage(),
          FollowingPage(),
          SearchPage(),
          SavedPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ], // background color
        ),
        padding: const EdgeInsets.only(bottom: 12), // pushes nav bar UP
        child: NavigationBar(
          backgroundColor: Colors.white, // change nav bar color
          indicatorColor: Colors.grey.shade200, // selected tab indicator
          height: 65, // makes it taller
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home, color: Colors.black), label: ''),
            NavigationDestination(
              icon: Icon(Icons.folder_copy, color: Colors.black),
              label: '',
            ),
            NavigationDestination(icon: Icon(Icons.search, color: Colors.black), label: ''),
            NavigationDestination(icon: Icon(Icons.bookmark, color: Colors.black), label: ''),
            NavigationDestination(icon: Icon(Icons.person, color: Colors.black), label: ''),
          ],
          selectedIndex: currentPage,
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
        ),
      ),
    );
  }
}
