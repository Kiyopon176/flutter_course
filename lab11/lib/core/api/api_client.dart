import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// The only class that talks to the wire. Everything it gives back is either
/// decoded JSON (`dynamic`) or one of our [ApiException]s — never a Response.
class ApiClient {
  ApiClient(
    this._client, {
    this.host = 'jsonplaceholder.typicode.com',
    this.timeout = const Duration(seconds: 10),
  });

  final http.Client _client;
  final String host;
  final Duration timeout;

  Map<String, String> get headers => const {'Accept': 'application/json'};

  Future<dynamic> get(Uri uri) async {
    final r = await _send(() => _client.get(uri, headers: headers));
    _check(r);
    return _decode(r);
  }

  Future<dynamic> post(Uri uri, String body, {int expect = 201}) async {
    final r = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: body,
      ),
    );
    _check(r);
    if (r.statusCode != expect) {
      throw BadResponseException('expected $expect, got ${r.statusCode}');
    }
    return _decode(r);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final sw = Stopwatch()..start();
    try {
      final r = await call().timeout(timeout);
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} → ${r.statusCode} '
          '(${r.bodyBytes.length} B, ${sw.elapsedMilliseconds} ms)',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // the http package wraps socket failures in ClientException on some platforms
      throw const NoConnectionException();
    }
  }

  // Status first, body second — always.
  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s < 200 || s >= 300) throw BadResponseException('HTTP $s');
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }
}
