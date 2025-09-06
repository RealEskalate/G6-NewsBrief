import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart'; // For PageTransitionSwitcher
import 'package:easy_localization/easy_localization.dart';

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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePage(onBookmarkTap: () {
        setState(() {
          currentPage = 3; // Switch to SavedPage tab
        });
      }),
      const FollowingPage(),
      const SearchPage(),
      const SavedPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final backgroundColor = theme.scaffoldBackgroundColor; // Correct dark/light
    final indicatorColor = theme.colorScheme.surfaceVariant;
    final secondaryColor = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: backgroundColor, // Uses AppTheme colors automatically

      // Animated page transitions
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
        child: _pages[currentPage],
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
              if (name.isNotEmpty) firstLetter = name[0].toUpperCase();
            }

            return NavigationBar(
              backgroundColor: backgroundColor,
              indicatorColor: indicatorColor,
              height: 65,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home,
                    color: currentPage == 0 ? secondaryColor : textColor,
                  ),
                  label: 'home'.tr(),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.folder_copy,
                    color: currentPage == 1 ? secondaryColor : textColor,
                  ),
                  label: 'following'.tr(),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.search,
                    color: currentPage == 2 ? secondaryColor : textColor,
                  ),
                  label: 'search'.tr(),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.bookmark,
                    color: currentPage == 3 ? secondaryColor : textColor,
                  ),
                  label: 'saved'.tr(),
                ),
                NavigationDestination(
                  icon: firstLetter != null
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: CircleAvatar(
                            backgroundColor: currentPage == 4
                                ? secondaryColor
                                : textColor.withOpacity(0.2),
                            child: Text(
                              firstLetter,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: currentPage == 4 ? secondaryColor : textColor,
                        ),
                  label: 'profile'.tr(),
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
