
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late var _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _showChangeName = false;
  bool _showResetPassword = false;
  TokenSecureStorage storage = TokenSecureStorage();
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ""); // default empty
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String? fullName;
        String? firstLetter;
        if (state is AuthAuthenticated) {
          fullName = state.user.fullName;
          _nameController.text = state.user.fullName;
          if (fullName.isNotEmpty) {
            firstLetter = fullName[0].toUpperCase();
          } else {
            firstLetter = "J"; // fallback
          }
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade100,
                        child: Text(
                          firstLetter ?? "J",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Change Name button
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.black,
                  ),
                  title: const Text("Change Name"),
                  trailing: Icon(
                    _showChangeName ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    setState(() => _showChangeName = !_showChangeName);
                  },
                ),
                if (_showChangeName) ...[
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    label: "Name",
                    icon: Icons.person,
                    maxLength: 30,
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Change',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ],

                // Reset Password button
                ListTile(
                  leading: const Icon(Icons.key, color: Colors.black),
                  title: const Text("Reset Password"),
                  trailing: Icon(
                    _showResetPassword ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    setState(() => _showResetPassword = !_showResetPassword);
                  },
                ),
                if (_showResetPassword) ...[
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _oldPasswordController,
                    label: "Old Password",
                    icon: Icons.key,
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _newPasswordController,
                    label: "New Password",
                    icon: Icons.key_rounded,
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () async {
                      final token = await storage
                          .readAccessToken(); // token is now String? instead of Future<String?>
                      if (token != null) {
                        context.read<AuthCubit>().resetPassword(
                          password: _oldPasswordController.text,
                          token: token,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No valid token found")),
                        );
                      }
                    },
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        counterText: "",
      ),
    );
  }
}
