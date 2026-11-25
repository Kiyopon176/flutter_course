import 'dart:developer';

import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';

// JSON → User at the repository boundary.
//
// User.fromJson stays strict: `as String` is a claim, and when the server
// breaks it the cast throws a TypeError right where the claim is (#0 in the
// trace). Repositories call these functions instead, which turn that
// TypeError into a BadResponseException — an ApiException the model already
// knows how to show — so a broken payload becomes an error view, not a crash.

User parseUser(Object? json) {
  final map = json is Map<String, dynamic> ? json : null;
  try {
    if (map == null) throw TypeError();
    return User.fromJson(map);
  } on TypeError catch (e, st) {
    final id = map?['id'];
    log(
      'user $id does not match the contract',
      name: 'users',
      error: e,
      stackTrace: st,
    );
    throw BadResponseException('users: user $id — $e');
  }
}

List<User> parseUsers(Object? json) {
  if (json is! List) {
    throw const BadResponseException('users: expected a JSON list');
  }
  return json.map(parseUser).toList();
}
