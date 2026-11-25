import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

/// Screens ask this class for [User]s and get [User]s — or an [ApiException].
class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final json = await _api.get(Uri.https(_api.host, '/users'));
    return _parse(
      'users',
      () => (json as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<User> getById(int id) async {
    final json = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// The server assigns the id, so the draft's id is not sent.
  Future<User> create(User draft) async {
    final body = jsonEncode(draft.toJson()..remove('id'));
    final json = await _api.post(Uri.https(_api.host, '/users'), body);
    return _parse(
      'POST users',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  // A cast or a parse that fails inside fromJson is the server's JSON not
  // matching our claims — a bug report, not a Retry.
  T _parse<T>(String where, T Function() fromJson) {
    try {
      return fromJson();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
