import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: "Confirm Password",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("Sign Up"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Already have an account? Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/root');
              },
              child: const Text("Continue as guest"),
            ),
          ],
        ),
      ),
    );
  }
}