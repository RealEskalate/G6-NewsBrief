import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';
import 'interests.dart';

class SignupEmailPage extends StatefulWidget {
  const SignupEmailPage({super.key});

  @override
  State<SignupEmailPage> createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool agreeToTerms = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? fullNameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();

    fullNameController.addListener(() {
      final name = fullNameController.text.trim();
      setState(() {
        fullNameError = name.length >= 3 ? null : "Full name must be at least 3 characters";
      });
    });

    emailController.addListener(() {
      final email = emailController.text.trim();
      final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
      setState(() {
        emailError = emailRegex.hasMatch(email) ? null : "Enter a valid email";
      });
    });

    passwordController.addListener(() {
      final password = passwordController.text;
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
      setState(() {
        passwordError = passwordRegex.hasMatch(password)
            ? null
            : "Password must be 8+ chars, include uppercase, lowercase, number & special char";
      });

      final confirm = confirmPasswordController.text;
      confirmPasswordError = (confirm == password) ? null : "Passwords do not match";
    });

    confirmPasswordController.addListener(() {
      final password = passwordController.text;
      final confirm = confirmPasswordController.text;
      setState(() {
        confirmPasswordError = (confirm == password) ? null : "Passwords do not match";
      });
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get isFormValid =>
      fullNameError == null &&
          emailError == null &&
          passwordError == null &&
          confirmPasswordError == null &&
          agreeToTerms &&
          fullNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'app_name'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'signup_with_email'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: 'full_name'.tr(),
                  border: const OutlineInputBorder(),
                  errorText: fullNameError,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'email'.tr(),
                  border: const OutlineInputBorder(),
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'password'.tr(),
                  border: const OutlineInputBorder(),
                  errorText: passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'confirm_password'.tr(),
                  border: const OutlineInputBorder(),
                  errorText: confirmPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'agree_terms'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inter',
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              BlocConsumer<AuthCubit, AuthState>(
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
                  } else if (state is AuthEmailActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is AuthError) {
                    // ✅ Check if error contains "already registered"
                    final msg = state.message.contains("already registered")
                        ? "This email is already registered."
                        : state.message;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomHoverButton(
                    iconWidget: Icon(Icons.email, color: theme.colorScheme.onPrimary),
                    text: state is AuthLoading ? 'signing_up'.tr() : 'sign_up'.tr(),
                    color: theme.colorScheme.primary,
                    textColor: theme.colorScheme.onPrimary,
                    onTap: (state is! AuthLoading && isFormValid)
                        ? () {
                      context.read<AuthCubit>().register(
                        emailController.text,
                        passwordController.text,
                        fullNameController.text,
                      );
                    }
                        : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/root');
                },
                label: Text(
                  'continue_as_guest'.tr(),
                  style: TextStyle(color: theme.colorScheme.onBackground),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: theme.colorScheme.onBackground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Hover Button
class CustomHoverButton extends StatefulWidget {
  final Widget iconWidget;
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const CustomHoverButton({
    super.key,
    required this.iconWidget,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<CustomHoverButton> createState() => _CustomHoverButtonState();
}

class _CustomHoverButtonState extends State<CustomHoverButton>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(_controller);
  }

  void _onHover(bool hover) {
    setState(() => _hovering = hover);
    if (hover) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _hovering
                      ? [
                    BoxShadow(
                      color: Colors.black26,
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black12,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconWidget,
                    const SizedBox(width: 8),
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textColor,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
