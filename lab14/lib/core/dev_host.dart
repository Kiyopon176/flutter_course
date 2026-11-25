import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'env.dart';

/// A runtime API-host override for testers. It exists only in debug builds:
/// in release `override` is always null and the setter is a no-op, so the
/// host is exactly what was baked in with --dart-define.
class DevHostSetting extends ChangeNotifier {
  DevHostSetting(this._prefs);

  static const prefsKey = 'dev_api_host';
  final SharedPreferences _prefs;

  String? get override => kDebugMode ? _prefs.getString(prefsKey) : null;

  /// The host the app actually talks to.
  String get host => override ?? Env.host;

  Future<void> setOverride(String? value) async {
    if (!kDebugMode) return;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(prefsKey);
    } else {
      await _prefs.setString(prefsKey, trimmed);
    }
    notifyListeners();
  }
}
