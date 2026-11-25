// Hits the real jsonplaceholder.typicode.com. Skipped unless LIVE=1:
//   LIVE=1 flutter test test/live_api_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user_repository.dart';

void main() {
  final skip = Platform.environment['LIVE'] != '1';
  final repo = UserRepository(ApiClient(http.Client()));

  test('getAll → 10 users', () async {
    final users = await repo.getAll();
    expect(users, hasLength(10));
  }, skip: skip);

  test('getById(999) → NotFoundException', () {
    expect(repo.getById(999), throwsA(isA<NotFoundException>()));
  }, skip: skip);

  test('create → id 11', () async {
    final draft = await repo.getById(1);
    final created = await repo.create(draft);
    expect(created.id, 11);
  }, skip: skip);

  test('typo in host → NoConnectionException', () {
    final bad = UserRepository(
      ApiClient(http.Client(), host: 'jsonplaceholder.typicode.invalid'),
    );
    expect(bad.getAll(), throwsA(isA<NoConnectionException>()));
  }, skip: skip);
}
