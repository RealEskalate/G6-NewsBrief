import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final backgroundColor = theme.colorScheme.background;
    final indicatorColor = theme.colorScheme.surfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,
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
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? Colors.grey.shade100
                  : Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(bottom: 12),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            String? firstLetter;

            if (state is AuthAuthenticated) {
              final name = state.user.fullName;
              if (name.isNotEmpty) {
                firstLetter = name[0].toUpperCase();
              }
            }

            return NavigationBar(
              backgroundColor: backgroundColor,
              indicatorColor: indicatorColor,
              height: 65,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home, color: textColor),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_copy, color: textColor),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search, color: textColor),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark, color: textColor),
                  label: '',
                ),
                NavigationDestination(
                  icon: firstLetter != null
                      ? SizedBox(
                    width: 30,
                    height: 30,
                    child: CircleAvatar(
                      backgroundColor: textColor,
                      child: Text(
                        firstLetter,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  )
                      : Icon(Icons.person, color: textColor),
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
