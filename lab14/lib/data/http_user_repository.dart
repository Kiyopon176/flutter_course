import '../core/api_client.dart';
import '../domain/user_repository.dart';
import 'user_json.dart';
import 'users_cache.dart';

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api, {UsersCache? cache, DateTime Function()? now})
    : _cache = cache,
      _now = now ?? DateTime.now;

  final ApiClient _api;
  final UsersCache? _cache;
  final DateTime Function() _now;

  @override
  Future<UsersPage> fetchUsers() async {
    try {
      final json = await _api.getJson('/users') as List;
      final users = json
          .cast<Map<String, dynamic>>()
          .map(userFromJson)
          .toList();
      await _cache?.save(users, _now());
      return UsersPage(users);
    } on NetworkException catch (e) {
      final cached = _cache?.read();
      if (cached != null) return UsersPage(cached.users, cachedAt: cached.at);
      throw OfflineException(e.host, e.cause);
    }
  }
}
