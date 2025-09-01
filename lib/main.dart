import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_local_data_sourcs.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_remote_data_sources.dart';
import 'package:newsbrief/features/auth/datasource/repositories/auth_repository_impl.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_interests_usecase.dart';
import 'package:newsbrief/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'features/auth/presentation/pages/signup_landing.dart';
import 'package:newsbrief/features/auth/presentation/pages/login.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_edit.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_page.dart';
import 'package:newsbrief/features/auth/presentation/pages/setting.dart';
import 'package:newsbrief/features/news/presentation/pages/following_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/home_page.dart';
import 'package:newsbrief/features/news/presentation/pages/root_page.dart';
import 'package:newsbrief/features/news/presentation/pages/saved_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/search_page.dart';
import 'package:newsbrief/features/onboarding/datasources/local_storage.dart';
import 'package:newsbrief/features/onboarding/presentation/onboarding.dart';
import 'features/onboarding/domain/check_first_run.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/get_me.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/verify_email.dart';
import 'features/auth/domain/usecases/request_verification_email.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  const baseUrl = 'https://news-brief-core-api-excr.onrender.com/api/v1';

  final tokenStorage = TokenSecureStorage();
  final api = ApiService(baseUrl: baseUrl, tokenStorage: tokenStorage);
  final remote = AuthRemoteDataSources(api);
  final local = AuthLocalDataSource(tokenStorage);
  final repo = AuthRepositoryImpl(remote: remote, local: local);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            loginUser: LoginUser(repo),
            registerUser: RegisterUser(repo),
            getMe: GetMe(repo),
            logout: Logout(repo),
            forgotPassword: ForgotPassword(repo),
            resetPassword: ResetPassword(repo),
            verifyEmail: VerifyEmail(repo),
            requestVerificationEmail: RequestVerificationEmail(repo),
            loginWithGoogleUseCase: LoginWithGoogleUseCase(repo),
            getInterestsUseCase: GetInterestsUseCase(repo),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CheckFirstRun checkFirstRun = CheckFirstRun(LocalStorage());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsBrief',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const SignupLandingPage(),
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
            return const Login(); // 👈 or SignupLandingPage, depending on your flow
          }
        },
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
