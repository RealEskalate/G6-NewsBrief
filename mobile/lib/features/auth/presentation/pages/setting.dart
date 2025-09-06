import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/features/auth/presentation/widgets/list_tile_items.dart';
import 'package:newsbrief/features/auth/presentation/widgets/section_header.dart';
import '../../../../core/theme/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _audioSpeed = 1.0;
  bool _notificationsEnabled = false;
  final TokenSecureStorage storage = TokenSecureStorage();

  void _showPushNotificationsDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Push Notifications".tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onBackground,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Do you want to enable push notifications?".tr(),
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.8)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Enable Notifications".tr(),
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _togglePushNotifications(value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close".tr(),
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePushNotifications(bool enable) {
    print(enable ? "Push notifications enabled.".tr() : "Push notifications disabled.".tr());
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Delete Account".tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onBackground),
          ),
          content: Text(
            "Are you sure you want to delete your account? This action cannot be undone.".tr(),
            style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr(), style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount();
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    print("User account is being deleted.".tr());
  }

  void _showLogoutDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Log Out".tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onBackground)),
          content: Text("Are you sure you want to log out?".tr(),
              style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.8))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr(), style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Navigate back
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<bool> appearanceSelection = [!isDark, isDark];
    final currentLocale = context.locale;
    List<bool> languageSelection = [
      currentLocale.languageCode == 'en',
      currentLocale.languageCode == 'am'
    ];

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Settings".tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: theme.colorScheme.onBackground),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
        SectionHeader(title: "Account".tr()),
    ListTileItem(title: "Edit Profile".tr(), onTap: () => Navigator.pushNamed(context, '/edit')),
    ListTileItem(title: "Delete Account".tr(), onTap: _showDeleteAccountDialog),
    ListTileItem(title: "Push notifications".tr(), onTap: _showPushNotificationsDialog),

    const SizedBox(height: 20),
    SectionHeader(title: "Configure NewsBrief".tr()),

    // Appearance Toggle
    ListTile(
    title: Text("Appearance".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    trailing: SizedBox(
    width: 100,
    child: ToggleButtons(
    borderRadius: BorderRadius.circular(12),
    isSelected: appearanceSelection,
    fillColor: isDark ? const Color(0xFF1E90FF) : theme.colorScheme.primary,
    selectedColor: Colors.white,
    color: isDark ? Colors.grey[300] : Colors.black,
    onPressed: (index) {
    if ((index == 0 && isDark) || (index == 1 && !isDark)) {
    context.read<ThemeCubit>().toggleTheme();
    }
    },
    children: [
    Center(child: Text("Light".tr())),
    Center(child: Text("Dark".tr())),
    ],
    ),
    ),
    ),

    // Language Toggle
              // Language Toggle
              ListTile(
                title: Text("Language".tr(), style: const TextStyle(fontSize: 16)),
                trailing: SizedBox(
                  width: 100,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    isSelected: languageSelection,
                    fillColor: isDark ? const Color(0xFF1E90FF) : theme.colorScheme.primary, // same as appearance button
                    selectedColor: Colors.white,
                    color: isDark ? Colors.grey[300] : Colors.black,
                    onPressed: (index) {
                      Locale newLocale = (index == 0) ? const Locale('en') : const Locale('am');
                      context.setLocale(newLocale);
                    },
                    children: [
                      Center(child: Text("English")),
                      Center(child: Text("አማርኛ")),
                    ],
                  ),
                ),
              ),


              // Audio Speed
    ListTile(
    title: Text("Audio Speed".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    trailing: SizedBox(
    width: 150,
    child: Row(
    children: [
    Expanded(
    child: Slider(
    min: 0.5,
    max: 2.0,
    divisions: 6,
    activeColor: theme.colorScheme.primary,
    thumbColor: theme.colorScheme.primary,
    value: _audioSpeed,
    onChanged: (value) {
    setState(() {
    _audioSpeed = value;
    });
    },
    ),
    ),
    Text("${_audioSpeed.toStringAsFixed(1)}x",
    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
    ],
    ),
    ),
    ),

    const SizedBox(height: 20),
    SectionHeader(title: "Legal".tr()),
    ListTileItem(title: "Terms of Service".tr(), onTap: () {}),
    ListTileItem(title: "Privacy Policy".tr(), onTap: () {}),

    const SizedBox(height: 16),
    const Divider(thickness: 1),
    const SizedBox(height: 16),

    ListTile(
    leading: const Icon(Icons.logout, color: Colors.red),
    title: const Text(
    "Log Out",
    style: TextStyle(color: Colors.red, fontSize: 18, fontWeight:FontWeight.w600),
    ),
      onTap: _showLogoutDialog,
    ),
            ],
        ),
    );
  }
}

