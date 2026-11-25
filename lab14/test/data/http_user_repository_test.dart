import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users/core/api_client.dart';
import 'package:users/data/http_user_repository.dart';
import 'package:users/data/users_cache.dart';
import 'package:users/domain/user_repository.dart';

const _body = [
  {
    'id': 1,
    'name': 'Leanne Graham',
    'username': 'Bret',
    'email': 'Sincere@april.biz',
    'address': {'city': 'Gwenborough'},
    'company': {'name': 'Romaguera-Crona'},
  },
];

void main() {
  late SharedPreferences prefs;
  final t0 = DateTime.utc(2026, 11, 25, 10);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  HttpUserRepository repo(MockClient client) => HttpUserRepository(
    ApiClient(client, host: 'api.test'),
    cache: UsersCache(prefs),
    now: () => t0,
  );

  final online = MockClient((req) async {
    expect(req.url.toString(), 'https://api.test/users');
    return http.Response(jsonEncode(_body), 200);
  });
  final offline = MockClient(
    (_) async => throw http.ClientException('Failed host lookup'),
  );

  test('online: parses users and is not from cache', () async {
    final page = await repo(online).fetchUsers();
    expect(page.users.single.name, 'Leanne Graham');
    expect(page.users.single.city, 'Gwenborough');
    expect(page.fromCache, isFalse);
  });

  test('offline after a good fetch: returns the saved list', () async {
    await repo(online).fetchUsers();
    final page = await repo(offline).fetchUsers();
    expect(page.fromCache, isTrue);
    expect(page.cachedAt, t0);
    expect(page.users.single.email, 'Sincere@april.biz');
  });

  test('offline with nothing saved: OfflineException naming the host', () {
    expect(
      repo(offline).fetchUsers(),
      throwsA(
        isA<OfflineException>().having((e) => e.host, 'host', 'api.test'),
      ),
    );
  });

  test('server error is not treated as offline', () {
    final broken = MockClient((_) async => http.Response('nope', 500));
    expect(repo(broken).fetchUsers(), throwsA(isA<ApiException>()));
  });

  test('host with a port and an explicit scheme', () {
    final c = ApiClient(online, host: 'http://10.0.2.2:8080');
    expect(c.uri('/users').toString(), 'http://10.0.2.2:8080/users');
  });
}
