import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user.dart';
import 'user_json.dart';

/// The last good list, so an airplane-mode launch still shows people.
class UsersCache {
  UsersCache(this._prefs);

  static const _usersKey = 'users_cache_v1';
  static const _timeKey = 'users_cache_time_v1';
  final SharedPreferences _prefs;

  Future<void> save(List<User> users, DateTime at) async {
    await _prefs.setString(
      _usersKey,
      jsonEncode(users.map(userToJson).toList()),
    );
    await _prefs.setString(_timeKey, at.toIso8601String());
  }

  ({List<User> users, DateTime at})? read() {
    final raw = _prefs.getString(_usersKey);
    final time = DateTime.tryParse(_prefs.getString(_timeKey) ?? '');
    if (raw == null || time == null) return null;
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(userFromJson)
        .toList();
    return (users: list, at: time);
  }
}
