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
  final TokenSecureStorage storage = TokenSecureStorage();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ""); // default empty
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String? fullName;
        String? firstLetter;
        if (state is AuthAuthenticated) {
          fullName = state.user.fullName;
          _nameController.text = state.user.fullName;
          firstLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : "J";
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Edit Profile",
              style: TextStyle(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
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
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        child: Text(
                          firstLetter ?? "J",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.edit,
                            color: theme.colorScheme.onPrimary,
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
                  leading: Icon(Icons.person_outline, color: theme.colorScheme.onBackground),
                  title: Text("Change Name", style: TextStyle(color: theme.colorScheme.onBackground)),
                  trailing: Icon(
                    _showChangeName ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  onTap: () => setState(() => _showChangeName = !_showChangeName),
                ),
                if (_showChangeName) ...[
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameController,
                    label: "Name",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Change',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 15),
                    ),
                  ),
                ],

                // Reset Password button
                ListTile(
                  leading: Icon(Icons.key, color: theme.colorScheme.onBackground),
                  title: Text("Reset Password", style: TextStyle(color: theme.colorScheme.onBackground)),
                  trailing: Icon(
                    _showResetPassword ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  onTap: () => setState(() => _showResetPassword = !_showResetPassword),
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
                      final token = await storage.readAccessToken();
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
                    child: Text(
                      'Change',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 15),
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
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      style: TextStyle(color: theme.colorScheme.onBackground),
    );
  }
}
