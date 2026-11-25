import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

import 'fixtures.dart';

UserRepository _repo(
  MockClientHandler handler, {
  Duration timeout = const Duration(seconds: 10),
}) => UserRepository(ApiClient(MockClient(handler), timeout: timeout));

http.Response _json(String body, int status) => http.Response(
  body,
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test(
    'getAll builds the address with Uri.https and parses the list',
    () async {
      late http.Request seen;
      final users = await _repo((r) async {
        seen = r;
        return _json(usersJson, 200);
      }).getAll();
      expect(seen.url.toString(), 'https://jsonplaceholder.typicode.com/users');
      expect(seen.headers['Accept'], 'application/json');
      expect(users.map((u) => u.name), ['Leanne Graham', 'Ervin Howell']);
    },
  );

  test('404 → NotFoundException (status is checked before the body)', () {
    expect(
      _repo((_) async => _json('{}', 404)).getById(999),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('401 → UnauthorizedException', () {
    expect(
      _repo((_) async => _json('{}', 401)).getById(1),
      throwsA(isA<UnauthorizedException>()),
    );
  });

  test('503 → ServerException(503)', () {
    expect(
      _repo((_) async => _json('oops', 503)).getAll(),
      throwsA(isA<ServerException>().having((e) => e.status, 'status', 503)),
    );
  });

  test('200 with a body that is not JSON → BadResponseException', () {
    expect(
      _repo((_) async => _json('<html>', 200)).getAll(),
      throwsA(isA<BadResponseException>()),
    );
  });

  test(
    '200 with {} → fromJson throws → BadResponseException naming users/1',
    () {
      expect(
        _repo((_) async => _json('{}', 200)).getById(1),
        throwsA(
          isA<BadResponseException>().having(
            (e) => e.detail,
            'detail',
            startsWith('users/1:'),
          ),
        ),
      );
    },
  );

  test('SocketException → NoConnectionException', () {
    expect(
      _repo((_) => throw const SocketException('no route')).getAll(),
      throwsA(isA<NoConnectionException>()),
    );
  });

  test('a server that never answers → timeout → NoConnectionException', () {
    expect(
      _repo(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 50),
      ).getAll(),
      throwsA(isA<NoConnectionException>()),
    );
  });

  test('create POSTs JSON without id and returns the server id', () async {
    late http.Request seen;
    final draft = User.fromJson(jsonDecode(user1Json) as Map<String, dynamic>);
    final created = await _repo((r) async {
      seen = r;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      return _json(jsonEncode({...body, 'id': 11}), 201);
    }).create(draft);

    expect(seen.method, 'POST');
    expect(seen.headers['Content-Type'], startsWith('application/json'));
    expect((jsonDecode(seen.body) as Map).containsKey('id'), isFalse);
    expect(created.id, 11);
    expect(created.name, draft.name);
  });

  test('create that does not get 201 → BadResponseException', () {
    final draft = User.fromJson(jsonDecode(user1Json) as Map<String, dynamic>);
    expect(
      _repo((_) async => _json(user1Json, 200)).create(draft),
      throwsA(isA<BadResponseException>()),
    );
  });
}
