import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/core/navigation/app_navigator.dart';
import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_local_data_sourcs.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_remote_data_sources.dart';
import 'package:newsbrief/features/auth/datasource/repositories/auth_repository_impl.dart';
import 'package:newsbrief/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:newsbrief/features/auth/domain/usecases/login_user.dart';
import 'package:newsbrief/features/auth/domain/usecases/register_user.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_me.dart';
import 'package:newsbrief/features/auth/domain/usecases/logout.dart';
import 'package:newsbrief/features/auth/domain/usecases/forgot_password.dart';
import 'package:newsbrief/features/auth/domain/usecases/reset_password.dart';
import 'package:newsbrief/features/auth/domain/usecases/verify_email.dart';
import 'package:newsbrief/features/auth/domain/usecases/request_verification_email.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/pages/login.dart';
import 'package:newsbrief/features/auth/presentation/pages/signup_landing.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_edit.dart';
import 'package:newsbrief/features/auth/presentation/pages/profile_page.dart';
import 'package:newsbrief/features/auth/presentation/pages/setting.dart';
import 'package:newsbrief/features/news/presentation/pages/following_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/home_page.dart';
import 'package:newsbrief/features/news/presentation/pages/root_page.dart';
import 'package:newsbrief/features/news/presentation/pages/saved_pages.dart';
import 'package:newsbrief/features/news/presentation/pages/search_page.dart';
import 'package:newsbrief/features/onboarding/presentation/onboarding.dart';
import 'package:newsbrief/features/onboarding/datasources/local_storage.dart';
import 'package:newsbrief/features/onboarding/domain/check_first_run.dart';

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

      // Use onGenerateRoute for all named routes
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/login':
            page = const Login();
            break;
          case '/signup':
            page = const SignupLandingPage();
            break;
          case '/edit':
            page = const EditProfilePage();
            break;
          case '/setting':
            page = const SettingsPage();
            break;
          case '/root':
            page = const RootPage();
            break;
          case '/home':
            page = const HomePage();
            break;
          case '/following':
            page = const FollowingPage();
            break;
          case '/search':
            page = const SearchPage();
            break;
          case '/saved':
            page = const SavedPage();
            break;
          case '/profile':
            page = const ProfilePage();
            break;
          default:
            page = const Login();
        }

        return AppNavigator.slidePageRoute(page);
      },

      // Initial screen for onboarding
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
            return const Login();
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

        // Use AppNavigator for consistent slide transition
        AppNavigator.pushReplacement(context, const Login());
      },
    );
  }
}
