import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/datasource/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_interests_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/signup.dart';

void main() {
  final authRepository = AuthRepositoryImpl();

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(
        signUpUseCase: SignUpUseCase(authRepository),
        getInterestsUseCase: GetInterestsUseCase(authRepository),
      ),
      child: const NewsBriefApp(),
    ),
  );
}

class NewsBriefApp extends StatelessWidget {
  const NewsBriefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsBrief',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}