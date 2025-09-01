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
    return Scaffold(
      backgroundColor: Colors.white,
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
              print('name $name');
              if (name.isNotEmpty) {
                firstLetter = name[0].toUpperCase();
                print("user Authcaited");
              }
            } else {
              print("user UnAuthcaited");
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
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Text(
                              firstLetter,
                              style: const TextStyle(color: Colors.white),
                            ),
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
