import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:newsbrief/core/navigation/app_navigator.dart';

import 'package:easy_localization/easy_localization.dart'; // <-- added

import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_local_data_sourcs.dart';
import 'package:newsbrief/features/auth/datasource/datasources/auth_remote_data_sources.dart';
import 'package:newsbrief/features/auth/datasource/repositories/auth_repository_impl.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_all_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_all_topic.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_interests_usecase.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_subscribed_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_subscribed_topics.dart';
import 'package:newsbrief/features/auth/domain/usecases/login_with_google_usecase.dart';

import 'package:newsbrief/features/auth/domain/usecases/login_user.dart';
import 'package:newsbrief/features/auth/domain/usecases/register_user.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_me.dart';
import 'package:newsbrief/features/auth/domain/usecases/logout.dart';
import 'package:newsbrief/features/auth/domain/usecases/forgot_password.dart';
import 'package:newsbrief/features/auth/domain/usecases/reset_password.dart';
import 'package:newsbrief/features/auth/domain/usecases/subscrible_to_topics.dart';
import 'package:newsbrief/features/auth/domain/usecases/unsubscrible_to_topic.dart';
import 'package:newsbrief/features/auth/domain/usecases/update_me.dart';
import 'package:newsbrief/features/auth/domain/usecases/verify_email.dart';
import 'package:newsbrief/features/auth/domain/usecases/request_verification_email.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:newsbrief/features/auth/domain/usecases/subscribe_to_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/unsubscribe_from_source.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';
import 'package:newsbrief/features/news/datasource/datasources/news.local_data_sources.dart';
import 'package:newsbrief/features/news/datasource/datasources/news_remote_data_sources.dart';
import 'package:newsbrief/features/news/datasource/repositories/news_repositorty_impl.dart';
import 'package:newsbrief/features/news/presentation/cubit/bookmark_cubit.dart';
import 'package:newsbrief/features/news/presentation/cubit/chat_cubit.dart';
import 'package:newsbrief/features/news/presentation/cubit/news_cubit.dart';
import 'package:newsbrief/features/news/presentation/pages/news_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'core/storage/theme_storage.dart';
import 'core/theme/theme_cubit.dart';

import 'features/auth/presentation/pages/admin_dashboard.dart';
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
import 'package:newsbrief/features/onboarding/presentation/onboarding.dart';
import 'package:newsbrief/features/onboarding/datasources/local_storage.dart';
import 'package:newsbrief/features/onboarding/domain/check_first_run.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // <-- initialize EasyLocalization

  const baseUrl = 'https://news-brief-core-api.onrender.com/api/v1';

  final themeStorage = ThemeStorage();
  final tokenStorage = TokenSecureStorage();
  final api = ApiService(baseUrl: baseUrl, tokenStorage: tokenStorage);
  final remote = AuthRemoteDataSources(api);
  final local = AuthLocalDataSource(tokenStorage);
  final repo = AuthRepositoryImpl(remote: remote, local: local);
  final newsRemote = NewsRemoteDataSources(api);
  final prefs = await SharedPreferences.getInstance();
  final newsLocal = NewsLocalDataSourceImpl(prefs);
  final newsRepo = NewsRepositoryImpl(newsRemote, newsLocal);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('am')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: MultiBlocProvider(
        providers: [
          
          BlocProvider(create: (_) => ChatCubit(newsRepo)),
          BlocProvider(create: (_) => BookmarkCubit(newsRepo)),
          BlocProvider(create: (_) => NewsCubit(newsRepo)..fetchForYouNews()),
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
              updateMe: UpdateMe(repo),
            ),
          ),

          BlocProvider(create: (_) => ThemeCubit(themeStorage)),

          BlocProvider(
            create: (_) => UserCubit(
              getAllSources: GetAllSources(repo),
              getAllTopic: GetAllTopic(repo),
              getSubscribedSources: GetSubscribedSources(repo),
              getSubscribedTopics: GetSubscribedTopics(repo),
              unsubscribeFromSource: UnsubscribeFromSource(repo),
              subscribeToSources: SubscribeToSources(repo),
              subscribeUseCase: SubscribeToTopics(repo),
              unsubscribeUseCase: UnsubscribeFromTopic(repo),
            ),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp(
          title: 'NewsBrief',
          debugShowCheckedModeBanner: false,
          theme: theme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // 🔹 Use onGenerateRoute so we can inject custom animations
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

              case '/news_detail':
                final args = settings.arguments as Map<String, dynamic>;
                page = NewsDetailPage(
                  id: args['id'] as String,
                  topics: args['topic'] as String,
                  title: args['title'] as String,
                  source: args['source'] as String,
                  imageUrl: args['imageUrl'] as String,
                  detail: args['detail'] as String,
                );
              case '/admin_dashboard': // <-- add this case
                page = const AdminDashboardPage();

                break;
              default:
                page = const Login();
            }
            return AppNavigator.slidePageRoute(page);
          },

          // 🔹 Initial screen for onboarding
          home: FutureBuilder<bool>(
            future: CheckFirstRun(LocalStorage()).shouldShowOnboarding(),
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
              return snapshot.data == true
                  ? OnboardingScreenWrapper(
                      checkFirstRun: CheckFirstRun(LocalStorage()),
                    )
                  : const Login();
            },
          ),
        );
      },
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
