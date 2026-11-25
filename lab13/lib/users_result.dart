import 'package:users_api/user.dart';

/// What `getAll()` returns: the users and where they came from.
class UsersResult {
  const UsersResult(this.users, {this.fromCache = false});

  final List<User> users;

  /// True when the network failed and these are the last good users.
  final bool fromCache;
}
