import 'user.dart';

/// What the UI gets: the users, and whether they came from the offline cache.
class UsersPage {
  const UsersPage(this.users, {this.cachedAt});

  final List<User> users;

  /// Non-null when the network failed and this is the last saved copy.
  final DateTime? cachedAt;

  bool get fromCache => cachedAt != null;
}

/// Thrown when the network is unreachable and there is nothing cached.
class OfflineException implements Exception {
  OfflineException(this.host, this.reason);
  final String host;
  final String reason;

  @override
  String toString() => 'Offline: cannot reach $host ($reason)';
}

abstract interface class UserRepository {
  Future<UsersPage> fetchUsers();
}
