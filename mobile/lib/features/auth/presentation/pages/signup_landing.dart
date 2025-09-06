import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';
import 'signup_email.dart';
import 'interests.dart';

class SignupLandingPage extends StatelessWidget {
  const SignupLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuthCubit>(),
                    child: const InterestsScreen(),
                  ),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back,
                            color: theme.colorScheme.onBackground),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "app_name".tr(),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "signup_tagline".tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "signup_description".tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthCubit>(),
                              child: const SignupEmailPage(),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.email, color: theme.colorScheme.onSurface),
                      label: Flexible(
                        child: Text(
                          "signup_with_email".tr(),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: Image.asset(
                        'assets/icons/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: state is AuthLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Flexible(
                        child: Text(
                          "signup_with_google".tr(),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: theme.colorScheme.onSurface),
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        context.read<AuthCubit>().loginWithGoogle();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthCubit>(),
                              child: const InterestsScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // ✅ Emit guest state
                      context.read<AuthCubit>().continueAsGuest();

                      // ✅ Navigate to RootPage
                      Navigator.pushReplacementNamed(context, '/root');
                    },
                    label: Text(
                      'continue_as_guest'.tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFamily: 'Inter',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: theme.colorScheme.onSurface),
                    ),
                  ),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      "already_have_account".tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
