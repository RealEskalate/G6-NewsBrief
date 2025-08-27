import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section 1: Account
          _buildSectionHeader("Account"),
          _buildListTile("Account"),
          _buildListTile("Manage Subscription"),

          const SizedBox(height: 12),

          // Section 2: Configure
          _buildSectionHeader("Configure NewsBrief"),
          _buildListTile(
            "Edit Profile",
            onTap: () {
              Navigator.pushNamed(context, '/edit');
            },
          ),
          _buildListTile("Manage Topics"),

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
              fillColor: Colors.grey[800],
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
                  child: Text("Light"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Dark"),
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
              fillColor: Colors.blue,
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

          _buildListTile("Push notifications"),

          // Audio Settings
          ListTile(
            title: const Text(
              "Audio Speed",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            subtitle: Slider(
              min: 0.5,
              max: 2.0,
              divisions: 6,
              activeColor: Colors.black,
              thumbColor: Color.fromARGB(255, 0, 0, 0),
              value: _audioSpeed,
              label: "${_audioSpeed.toStringAsFixed(1)}x",
              onChanged: (value) {
                setState(() {
                  _audioSpeed = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // Terms of Service
          _buildSectionHeader("Legal"),
          _buildListTile(
            "Terms of Service",
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),
          _buildListTile(
            "Privacy Policy",
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          const Divider(thickness: 1), // separates logout from the rest

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
            onTap: () {
              // Add your sign out logic here
            },
          ),
          
        ],
      ),
    );
  }

  // Reusable Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  // Reusable ListTile
  Widget _buildListTile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
