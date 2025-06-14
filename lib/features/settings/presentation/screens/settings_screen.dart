// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Notification Settings'),
            leading: Icon(Icons.notifications),
          ),
          ListTile(
            title: Text('Theme'),
            leading: Icon(Icons.color_lens),
          ),
        ],
      ),
    );
  }
}