import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  void _loginWithGoogle() {
    context.read<AuthCubit>().loginWithGoogle();
    Navigator.pushNamed(context, '/root');
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid email before resetting password.'.tr(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    context.read<AuthCubit>().forgotPasswordUsecase(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Login'.tr(),
            style: TextStyle(color: theme.colorScheme.onBackground)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final email = _emailController.text.trim();
            final password = _passwordController.text;

            if (email == "admin@newsbrief.local" &&
                password == "ChangeMe123!") {
              // Admin login
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(
                    context, '/admin_dashboard');
              });
            } else {
              // Normal user login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome User'.tr()),
                  backgroundColor: theme.colorScheme.primary,
                  duration: const Duration(seconds: 3),
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/root');
              });
            }
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email input
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email'.tr(),
                      labelStyle:
                      TextStyle(color: theme.colorScheme.onBackground),
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email,
                          color: theme.colorScheme.onBackground),
                    ),
                    style: TextStyle(color: theme.colorScheme.onBackground),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email'.tr();
                      if (!value.contains('@'))
                        return 'Please enter a valid email'.tr();
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password'.tr(),
                      labelStyle:
                      TextStyle(color: theme.colorScheme.onBackground),
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock,
                          color: theme.colorScheme.onBackground),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: theme.colorScheme.onBackground,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onBackground),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password'.tr();
                      if (value.length < 6)
                        return 'Password must be at least 6 characters'.tr();
                      return null;
                    },
                  ),

                  // Forgot password button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot Password?'.tr(),
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Text(
                        'Login'.tr(),
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Google Login Button
                  if (state is! AuthLoading)
                    OutlinedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                        'assets/icons/google_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      label: Text(
                        'Sign in with Google'.tr(),
                        style: TextStyle(color: theme.colorScheme.onBackground),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: theme.colorScheme.onBackground),
                      ),
                    ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/root');
                    },
                    label: Text(
                      'Continue as Guest'.tr(),
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: theme.colorScheme.onBackground),
                    ),
                  ),

                  // Sign Up Navigation
                  if (state is! AuthLoading)
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: theme.colorScheme.onBackground),
                          children: [
                            TextSpan(text: "Don't have an account? ".tr()),
                            TextSpan(
                              text: "Sign up".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
