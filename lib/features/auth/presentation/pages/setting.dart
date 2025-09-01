import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
// import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/widgets/list_tile_items.dart';
import 'package:newsbrief/features/auth/presentation/widgets/section_header.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // For toggles
  List<bool> _appearanceSelection = [false, true]; // Dark by default
  List<bool> _languageSelection = [true, false]; // English by default
  double _audioSpeed = 1.0; // Default audio speed
  bool _notificationsEnabled = false; // New state variable for notifications

  final TokenSecureStorage storage = TokenSecureStorage();
  // Function to show the push notifications dialog
  void _showPushNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Push Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Do you want to enable push notifications?"),
                  SwitchListTile(
                    title: const Text("Enable Notifications"),
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
              child: const Text("Close", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Placeholder function to handle toggling notifications
  void _togglePushNotifications(bool enable) {
    // Implement your logic to enable or disable push notifications here
    if (enable) {
      print("Push notifications enabled.");
      // Call a service or API to subscribe to notifications
    } else {
      print("Push notifications disabled.");
      // Call a service or API to unsubscribe from notifications
    }
  }

  // Function to show the delete account dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
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

  // Placeholder function to handle account deletion
  void _deleteAccount() {
    // Implement your logic to delete the user's account here
    print("User account is being deleted.");
    // Call a service or API to delete the account
  }

  // Function to show the logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // final token = await storage.readRefreshToken();
                // Perform the logout action here
                // context.read<AuthCubit>().logout(refreshToken: token);
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back from settings
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section 1: Account
          const SectionHeader(title: "Account"),
          ListTileItem(
            title: "Edit Profile",
            onTap: () {
              Navigator.pushNamed(context, '/edit');
            },
          ),
          ListTileItem(
            title: "Delete Account",
            onTap: _showDeleteAccountDialog,
          ),
          ListTileItem(
            title: "Push notifications",
            onTap: _showPushNotificationsDialog,
          ),

          // Section 2: Configure
          const SectionHeader(title: "Configure NewsBrief"),
          // Appearance Toggle
                   // Appearance Toggle
          ListTile(
            title: const Text(
              "Appearance",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            trailing: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey,
              selectedColor: Colors.white,
              fillColor: Colors.black,
              isSelected: _appearanceSelection,
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < _appearanceSelection.length; i++) {
                    _appearanceSelection[i] = (i == index);
                  }
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(" Light "),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(" Dark "),
                ),
              ],
            ),
          ),
          // Language Toggle
          ListTile(
            title: const Text(
              "Language",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            trailing: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey,
              selectedColor: Colors.white,
              fillColor: Colors.black,
              isSelected: _languageSelection,
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < _languageSelection.length; i++) {
                    _languageSelection[i] = (i == index);
                  }
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("English"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("አማርኛ"),
                ),
              ],
            ),
          ),
          // Audio Settings
          ListTile(
            title: const Text(
              "Audio Speed",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            trailing: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      activeColor: Colors.black,
                      thumbColor: Colors.black,
                      value: _audioSpeed,
                      onChanged: (value) {
                        setState(() {
                          _audioSpeed = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    "${_audioSpeed.toStringAsFixed(1)}x",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Section: Legal
          const SectionHeader(title: 'Legal'),
          ListTileItem(
            title: "Terms of Service",
            onTap: () {},
          ),
          ListTileItem(
            title: "Privacy Policy",
            onTap: () {},
          ),

          // Logout
          const SizedBox(height: 16),
          const Divider(thickness: 1), // separates logout from the rest
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Log Out",
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _showLogoutDialog, // Call the new logout dialog function
          ),
        ],
      ),
    );
  }
}