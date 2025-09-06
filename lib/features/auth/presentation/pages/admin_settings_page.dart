import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/theme_cubit.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  // Keep these as-is, no localization
  final String adminName = "Admin";
  final String adminEmail = "admin@newsbrief.local";

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
      appBar: AppBar(
        title: Text(
          "admin_settings".tr(),
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar & Email Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    adminName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  adminEmail,
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Appearance Toggle
          ListTile(
            title: Text(
              "appearance".tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: SizedBox(
              width: 100,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected: appearanceSelection,
                fillColor: isDark ? const Color(0xFF2563EB) : theme.colorScheme.primary,
                selectedColor: Colors.white,
                color: isDark ? Colors.grey[300] : Colors.black,
                onPressed: (index) {
                  if ((index == 0 && isDark) || (index == 1 && !isDark)) {
                    context.read<ThemeCubit>().toggleTheme();
                  }
                },
                children: [
                  Center(child: Text("light".tr())),
                  Center(child: Text("dark".tr())),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Language Toggle
          ListTile(
            title: Text("language".tr(), style: const TextStyle(fontSize: 16)),
            trailing: SizedBox(
              width: 100,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected: languageSelection,
                fillColor: isDark ? const Color(0xFF2563EB) : theme.colorScheme.primary,
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
        ],
      ),
    );
  }
}
