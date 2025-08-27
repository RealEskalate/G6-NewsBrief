import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/datasource/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/signup_landing.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_up_with_google_usecase.dart';
import 'features/auth/domain/usecases/get_interests_usecase.dart';
import 'features/onboarding/domain/check_first_run.dart';
import 'features/onboarding/datasources/local_storage.dart';
import 'features/onboarding/presentation/onboarding.dart';

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
        home: FutureBuilder<bool>(
          future: checkFirstRun.shouldShowOnboarding(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SignupLandingPage(),
          ),
        );
      },
    );
  }
}
