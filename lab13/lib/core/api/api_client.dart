import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:users_api/core/api/api_exception.dart';

/// The only class that knows about HTTP: status codes, JSON bodies, sockets.
/// Everything above it sees decoded JSON or an [ApiException].
class ApiClient {
  ApiClient({
    http.Client? client,
    this.host = defaultHost,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String host;
  final Duration timeout;

  static const defaultHost = 'jsonplaceholder.typicode.com';
  static const _headers = {'Accept': 'application/json'};

  Future<Object?> get(String path) =>
      _send(() => _client.get(_uri(path), headers: _headers));

  Future<Object?> post(String path, Map<String, Object?> body) => _send(
    () => _client.post(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    ),
  );

  Uri _uri(String path) => Uri.https(host, path);

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on SocketException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const TimeoutApiException();
    }
    _check(response);
    return _decode(response);
  }

  void _check(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) return;
    if (code == 401 || code == 403) throw const UnauthorizedException();
    if (code == 404) throw NotFoundException('${response.request?.url.path}');
    if (code >= 500) throw ServerException(code);
    throw BadResponseException('unexpected status $code');
  }

  Object? _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const BadResponseException('body is not JSON');
    }
  }
}
