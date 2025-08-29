import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/datasource/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/signup_landing.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_up_with_google_usecase.dart';
import 'features/auth/domain/usecases/get_interests_usecase.dart';
import 'package:newsbrief/features/auth/presentation/pages/login.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_edit.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_page.dart';
import 'package:newsbrief/features/auth/presentation/pages/setting.dart';
import 'package:newsbrief/features/auth/presentation/pages/sign_up.dart';
import 'package:newsbrief/features/news/presentation/pages/following_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/home_page.dart';
import 'package:newsbrief/features/news/presentation/pages/root_page.dart';
import 'package:newsbrief/features/news/presentation/pages/saved_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/search_page.dart';
import 'package:newsbrief/features/onboarding/datasources/local_storage.dart';
import 'package:newsbrief/features/onboarding/presentation/onboarding.dart';

import 'features/onboarding/domain/check_first_run.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final CheckFirstRun checkFirstRun = CheckFirstRun(LocalStorage());

  final AuthBloc authBloc = AuthBloc(
    signUpUseCase: SignUpUseCase(AuthRepositoryImpl()),
    getInterestsUseCase: GetInterestsUseCase(AuthRepositoryImpl()),
    signUpWithGoogleUseCase: SignUpWithGoogleUseCase(AuthRepositoryImpl()),
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp(
        title: 'NewsBrief',
        debugShowCheckedModeBanner: false,
        // define routes so LoginPage can easily navigate to SignUp/Home
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/edit': (context) => const EditProfilePage(),
          '/setting': (context) => const SettingsPage(),
          '/root': (context) => const RootPage(),
          '/home': (context) => const HomePage(),
          '/following': (context) => const FollowingPage(),
          '/search': (context) => const SearchPage(),
          '/saved': (context) => const SavedPage(),
          '/profile': (context) => const ProfilePage(),
        },
        home: FutureBuilder<bool>(
          future: checkFirstRun.shouldShowOnboarding(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            }
            if (snapshot.data == true) {
              return OnboardingScreenWrapper(checkFirstRun: checkFirstRun);
            } else {
              return const SignupLandingPage();
            }
          },
        ),
      ),
    );
  }
}

class OnboardingScreenWrapper extends StatelessWidget {
  final CheckFirstRun checkFirstRun;

  const OnboardingScreenWrapper({super.key, required this.checkFirstRun});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onFinish: () async {
        await checkFirstRun.completeOnboarding();
        // Use a single navigation method to avoid redundancy
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }
}