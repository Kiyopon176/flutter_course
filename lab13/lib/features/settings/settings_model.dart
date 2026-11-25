import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences, persisted with SharedPreferencesAsync.
class SettingsModel extends ChangeNotifier {
  final _prefs = SharedPreferencesAsync();

  static const _darkKey = 'dark_mode';

  bool darkMode = false;

  Future<void> load() async {
    darkMode = await _prefs.getBool(_darkKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    await _prefs.setBool(_darkKey, value);
  }
}
