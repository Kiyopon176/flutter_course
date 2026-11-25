import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/user.dart';
import 'package:users_api/users_cache.dart';
import 'package:users_api/users_result.dart';

/// Turns `/users` JSON into [User]s; falls back to the cache when offline.
class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<UsersResult> getAll() async {
    try {
      final json = await _api.get('/users');
      final users = (json as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache.save(users);
      return UsersResult(users);
    } on NoConnectionException {
      final cached = _cache.users;
      if (cached == null) rethrow;
      print('offline: serving ${cached.length} cached users');
      return UsersResult(cached, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final json = await _api.get('/users/$id');
    return User.fromJson(json as Map<String, dynamic>);
  }

  Future<User> create(User draft) async {
    final json = await _api.post('/users', draft.toJson());
    return User.fromJson(json as Map<String, dynamic>);
  }
}
