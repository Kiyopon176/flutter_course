import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../features/users/user.dart';
import '../features/users/user_repository.dart';

/// Levels 2 and 3 checks, run from main() before runApp:
///   flutter run --dart-define=SMOKE=true
Future<void> smoke(UserRepository repo) async {
  // Level 2: the real JSON of user 1, pasted from Postman.
  const raw = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';
  final user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  debugPrint('parsed: $user, geo ${user.address.geo}');
  debugPrint('round trip equal: ${User.fromJson(user.toJson()) == user}');

  // Level 3: the real server.
  final all = await repo.getAll();
  debugPrint('getAll: ${all.length} users');
  for (final u in all) {
    debugPrint('  ${u.name}');
  }

  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('getById(999): not found');
  }

  final created = await repo.create(user);
  debugPrint('create: server assigned id ${created.id}');
}
