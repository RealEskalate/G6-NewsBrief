import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart'; // <-- for PageTransitionSwitcher
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';
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

  final List<Widget> _pages = const [
    HomePage(),
    FollowingPage(),
    SearchPage(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 Instead of IndexedStack, use PageTransitionSwitcher for animation
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.ease));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        child: _pages[currentPage], // current page
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
          ],
        ),
        padding: const EdgeInsets.only(bottom: 12),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            String? firstLetter;

            if (state is AuthAuthenticated) {
              final name = state.user.email;
              if (name.isNotEmpty) {
                firstLetter = name[0].toUpperCase();
              }
            }

            return NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: Colors.grey.shade200,
              height: 65,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home, color: Colors.black),
                  label: '',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.folder_copy, color: Colors.black),
                  label: '',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.search, color: Colors.black),
                  label: '',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.bookmark, color: Colors.black),
                  label: '',
                ),
                NavigationDestination(
                  icon: firstLetter != null
                      ? CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(
                            firstLetter,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.black),
                  label: '',
                ),
              ],
              selectedIndex: currentPage,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
