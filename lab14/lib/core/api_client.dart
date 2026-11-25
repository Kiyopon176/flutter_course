import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// The server answered, but not with 200.
class ApiException implements Exception {
  ApiException(this.statusCode, this.uri);
  final int statusCode;
  final Uri uri;

  @override
  String toString() => 'HTTP $statusCode from $uri';
}

/// The server could not be reached at all (no network, DNS, timeout, TLS).
class NetworkException implements Exception {
  NetworkException(this.host, this.cause);
  final String host;
  final String cause;

  @override
  String toString() => 'Cannot reach $host ($cause)';
}

class ApiClient {
  ApiClient(this._client, {required this.host});

  final http.Client _client;

  /// `example.com`, `10.0.2.2:8080` or a full `http://…` base URL.
  final String host;

  static const _timeout = Duration(seconds: 10);

  Uri uri(String path) {
    final hasScheme = host.startsWith('http://') || host.startsWith('https://');
    return Uri.parse(hasScheme ? '$host$path' : 'https://$host$path');
  }

  Future<Object?> getJson(String path) async {
    final target = uri(path);
    final http.Response res;
    try {
      res = await _client.get(target).timeout(_timeout);
    } on http.ClientException catch (e) {
      throw NetworkException(host, e.message);
    } on SocketException catch (e) {
      throw NetworkException(host, e.message);
    } on HandshakeException catch (e) {
      throw NetworkException(host, e.message);
    } on TimeoutException {
      throw NetworkException(host, 'timeout');
    }
    if (res.statusCode != 200) throw ApiException(res.statusCode, target);
    return jsonDecode(res.body);
  }

  void close() => _client.close();
}
