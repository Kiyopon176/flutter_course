import 'package:users_api/user.dart';

/// Keeps the last list that came from the server, for offline mode.
class UsersCache {
  List<User>? _users;

  List<User>? get users => _users;

  void save(List<User> users) => _users = List.unmodifiable(users);
}
