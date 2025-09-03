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
  double _audioSpeed = 1.0; // Default audio speed
  bool _notificationsEnabled = false; // Notifications state
  final TokenSecureStorage storage = TokenSecureStorage();

  void _showPushNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Push Notifications".tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  ),
                  SwitchListTile(
                    title: Text(
                      "Enable Notifications".tr(),
                      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
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
              child: Text("Close".tr(), style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
            ),
          ],
        );
      },
    );
  }

  void _togglePushNotifications(bool enable) {
    if (enable) {
      print("Push notifications enabled.".tr());
    } else {
      print("Push notifications disabled.".tr());
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Delete Account".tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground)),
          content: Text(
            "Are you sure you want to delete your account? This action cannot be undone.".tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr(), style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount();
                Navigator.pop(context);
              },
              child: Text("Delete".tr(), style: TextStyle(color: Colors.red)),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Log Out".tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground)),
          content: Text("Are you sure you want to log out?".tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel".tr(), style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back from settings
              },
              child: Text("Log Out".tr(), style: TextStyle(color: Colors.red)),
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

    // Appearance toggle derived from current theme
    List<bool> appearanceSelection = [!isDark, isDark];

    // Language toggle derived from current locale
    final currentLocale = context.locale;
    List<bool> languageSelection = [
      currentLocale.languageCode == 'en',
      currentLocale.languageCode == 'am'
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("Settings".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SectionHeader(title: "Account".tr()),
          ListTileItem(title: "Edit Profile".tr(), onTap: () => Navigator.pushNamed(context, '/edit')),
          ListTileItem(title: "Delete Account".tr(), onTap: _showDeleteAccountDialog),
          ListTileItem(title: "Push notifications".tr(), onTap: _showPushNotificationsDialog),

          SectionHeader(title: "Configure NewsBrief".tr()),

          // Appearance Toggle
          ListTile(
            title: Text("Appearance".tr(), style: TextStyle(fontSize: 16)),
            trailing: SizedBox(
              width: 160,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected: appearanceSelection,
                fillColor: theme.colorScheme.primary,
                selectedColor: isDark ? Colors.black : Colors.white,
                color: isDark ? Colors.white : Colors.black,
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
          ListTile(
            title: Text("Language".tr(), style: TextStyle(fontSize: 16)),
            trailing: SizedBox(
              width: 160,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected: languageSelection,
                fillColor: theme.colorScheme.primary,
                selectedColor: isDark ? Colors.black : Colors.white,
                color: isDark ? Colors.white : Colors.black,
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
            title: Text("Audio Speed".tr(), style: TextStyle(fontSize: 16)),
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

          SectionHeader(title: "Legal".tr()),
          ListTileItem(title: "Terms of Service".tr(), onTap: () {}),
          ListTileItem(title: "Privacy Policy".tr(), onTap: () {}),

          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text("Log Out".tr(), style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w600)),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }
}
