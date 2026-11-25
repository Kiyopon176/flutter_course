import 'package:flutter/foundation.dart';
import 'package:users_api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/user.dart';
import 'package:users_api/user_repository.dart';
import 'package:users_api/users_cache.dart';

/// loading / error / items for the users list.
class UsersModel extends ChangeNotifier {
  final _repo = UserRepository(ApiClient(), UsersCache());

  bool loading = false;
  ApiException? error;
  bool fromCache = false;

  List<User> _all = const [];
  String _query = '';

  String get query => _query;
  int get total => _all.length;

  /// The list after the search filter (by name or city).
  List<User> get items {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.address.city.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      _all = result.users;
      fromCache = result.fromCache;
      print('loaded ${_all.length} users (cache: $fromCache)');
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Future<void> add(User draft) async {
    try {
      final created = await _repo.create(draft);
      _all = [..._all, created];
    } on ApiException catch (e) {
      error = e;
    }
    notifyListeners();
  }
}
