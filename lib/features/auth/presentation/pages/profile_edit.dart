import 'package:easy_localization/easy_localization.dart';
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
    _nameController = TextEditingController(text: "");

    // Listeners to refresh UI for enabling/disabling buttons and showing warnings
    _nameController.addListener(() => setState(() {}));
    _oldPasswordController.addListener(() => setState(() {}));
    _newPasswordController.addListener(() => setState(() {}));
  }

  bool get _isChangeNameEnabled => _nameController.text.trim().isNotEmpty;

  bool get _isResetPasswordEnabled {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    return oldPass.isNotEmpty && newPass.isNotEmpty && oldPass != newPass;
  }

  bool get _showSamePasswordWarning {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    return oldPass.isNotEmpty && newPass.isNotEmpty && oldPass == newPass;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      _nameController.text = state.user.fullName;
    }
  },
  child: BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      String? fullName;
      String? firstLetter;

      if (state is AuthAuthenticated) {
        fullName = state.user.fullName;
        firstLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : "J";
      }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.onBackground,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Edit Profile".tr(),
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
                        child: Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Change Name Section
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.onBackground,
                  ),
                  title: Text(
                    "Change Name".tr(),
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                  trailing: Icon(
                    _showChangeName ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  onTap: () =>
                      setState(() => _showChangeName = !_showChangeName),
                ),
                if (_showChangeName) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: "Name".tr(),
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isChangeNameEnabled
                          ? () {
                              context.read<AuthCubit>().changeName(newName: 
                                _nameController.text.trim(),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Change'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Reset Password Section
                ListTile(
                  leading: Icon(
                    Icons.key,
                    color: theme.colorScheme.onBackground,
                  ),
                  title: Text(
                    "Reset Password".tr(),
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                  trailing: Icon(
                    _showResetPassword ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  onTap: () =>
                      setState(() => _showResetPassword = !_showResetPassword),
                ),
                if (_showResetPassword) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _oldPasswordController,
                    label: "Old Password".tr(),
                    icon: Icons.key,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _newPasswordController,
                    label: "New Password".tr(),
                    icon: Icons.key_rounded,
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),

                  // Animated Warning
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showSamePasswordWarning ? 1.0 : 0.0,
                    child: _showSamePasswordWarning
                        ? Text(
                            "New password must be different from old password"
                                .tr(),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isResetPasswordEnabled
                          ? () async {
                              final token = await storage.readAccessToken();
                              if (token != null) {
                                context.read<AuthCubit>().resetPassword(
                                  password: _oldPasswordController.text,
                                  token: token,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("No valid token found".tr()),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Change'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
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
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
