import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';

import '../../fixtures/users_json.dart';

/// The MockClient is why ApiClient takes an http.Client in its constructor.
HttpUserRepository repoWith(MockClientHandler handler, [UsersCache? cache]) =>
    HttpUserRepository(
      ApiClient(client: MockClient(handler)),
      cache ?? UsersCache(),
    );

void main() {
  group('HttpUserRepository maps the wire to exceptions', () {
    test('404 → NotFoundException', () async {
      final repo = repoWith(
        (_) async => http.Response('{"error":"gone"}', 404),
      );

      await expectLater(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 → ServerException', () async {
      final repo = repoWith((_) async => http.Response('oops', 500));

      await expectLater(repo.getById(1), throwsA(isA<ServerException>()));
    });

    test('SocketException → NoConnectionException', () async {
      final repo = repoWith((_) => throw const SocketException('down'));

      await expectLater(repo.getAll(), throwsA(isA<NoConnectionException>()));
    });
  });

  group('HttpUserRepository: the server broke the contract', () {
    test('"lat" as a number → BadResponseException, not a crash', () async {
      final broken = usersJson.replaceFirst('"-37.3159"', '-37.3159');
      final repo = repoWith((_) async => http.Response(broken, 200));

      await expectLater(repo.getAll(), throwsA(isA<BadResponseException>()));
    });

    test('a broken user by id → BadResponseException', () async {
      final broken = user1Json.replaceFirst('"-37.3159"', '-37.3159');
      final repo = repoWith((_) async => http.Response(broken, 200));

      await expectLater(repo.getById(1), throwsA(isA<BadResponseException>()));
    });
  });

  group('HttpUserRepository.getAll', () {
    test('200 → two users, not from cache', () async {
      final repo = repoWith((_) async => http.Response(usersJson, 200));

      final result = await repo.getAll();

      expect(result.users.map((u) => u.name), [
        'Leanne Graham',
        'Ervin Howell',
      ]);
      expect(result.fromCache, isFalse);
    });

    test('offline after one success → the cached users', () async {
      var online = true;
      final repo = repoWith((_) async {
        if (!online) throw const SocketException('down');
        return http.Response(usersJson, 200);
      });
      await repo.getAll();
      online = false;

      final result = await repo.getAll();

      expect(result.fromCache, isTrue);
      expect(result.users, hasLength(2));
    });
  });
}
