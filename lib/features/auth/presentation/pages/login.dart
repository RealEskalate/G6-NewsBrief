// presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
      context.read<AuthBloc>().add(LoginEvent(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    }
  }

  void _loginWithGoogle() {
    context.read<AuthBloc>().add(LoginWithGoogleEvent());
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black), // Black font color
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // White background
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Show success message instead of navigating
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful! Welcome ${state.user.fullName}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Comment out navigation until home page is ready
            // Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            // Show error message - fixed to use state.error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error), // Changed from state.message to state.error
                backgroundColor: Colors.red,
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
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black), // Black label
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.black), // Black icon
                    ),
                    style: const TextStyle(color: Colors.black), // Black text
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black), // Black label
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.black), // Black icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black, // Black icon
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.black), // Black text
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
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
                        backgroundColor: Colors.black, // Black button
                        foregroundColor: Colors.white, // White text
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white), // White text
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Google Login Button
                  if (state is! AuthLoading)
                    OutlinedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                      'assets/icons/google_logo.png', // Real Google icon
                        width: 24,
                        height: 24,
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.black), // Black text
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.black), // Black border
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Sign Up Navigation
                  if (state is! AuthLoading)
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black), // Black text
                          children: [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Bold signup text
                                color: Colors.black, // Black text
                              ),
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