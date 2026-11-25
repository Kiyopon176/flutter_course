import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/features/settings/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.darkMode,
            onChanged: settings.setDarkMode,
          ),
        ],
      ),
    );
  }
}
