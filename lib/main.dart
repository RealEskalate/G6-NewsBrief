import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/datasource/repositories/auth_repository_impl.dart';
import 'package:newsbrief/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:newsbrief/features/auth/presentation/pages/login.dart';
import 'package:newsbrief/features/onboarding/datasources/local_storage.dart';
import 'package:newsbrief/features/onboarding/presentation/onboarding.dart';
import 'features/onboarding/domain/check_first_run.dart';

// import your repository + use cases
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/get_interests_usecase.dart';
import 'features/auth/domain/usecases/sign_up_with_google_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/login_with_google_usecase.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final CheckFirstRun checkFirstRun = CheckFirstRun(LocalStorage());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // instantiate repository
    final authRepository = AuthRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            signUpUseCase: SignUpUseCase(authRepository),
            getInterestsUseCase: GetInterestsUseCase(authRepository),
            signUpWithGoogleUseCase: SignUpWithGoogleUseCase(authRepository),
            loginUseCase: LoginUseCase(authRepository),
            loginWithGoogleUseCase: LoginWithGoogleUseCase(authRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NewsBrief',
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: checkFirstRun.shouldShowOnboarding(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == true) {
              return OnboardingScreenWrapper(checkFirstRun: checkFirstRun);
            } else {
              return const Login();
            }
          },
        ),
      ),
    );
  }
}

/// Wrapper so your existing OnboardingScreen can call `completeOnboarding()`
class OnboardingScreenWrapper extends StatelessWidget {
  final CheckFirstRun checkFirstRun;

  const OnboardingScreenWrapper({super.key, required this.checkFirstRun});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onFinish: () async {
        await checkFirstRun.completeOnboarding();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Login()),
        );
      },
    );
  }
}
