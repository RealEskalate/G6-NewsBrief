import 'package:flutter/material.dart';
import 'package:newsbrief/features/auth/presentation/pages/login.dart';
import 'package:newsbrief/features/onboarding/datasources/local_storage.dart';
import 'package:newsbrief/features/onboarding/presentation/onboarding.dart';
import 'features/onboarding/domain/check_first_run.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final CheckFirstRun checkFirstRun = CheckFirstRun(LocalStorage());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsBrief',
      debugShowCheckedModeBanner: true,
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
