import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config.dart';
import 'api_exception.dart';
import 'token_store.dart';

typedef LogoutCallback = void Function();

class ApiClient {
  ApiClient({required this.tokens, this.onForceLogout});

  final TokenStore tokens;
  final LogoutCallback? onForceLogout;

  final http.Client _http = http.Client();

  // ── verbs ───────────────────────────────────────────────────────
  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, Map<String, String>? query}) =>
      _request('POST', path, body: body, query: query);

  Future<dynamic> patch(String path, {Object? body, Map<String, String>? query}) =>
      _request('PATCH', path, body: body, query: query);

  Future<dynamic> delete(String path, {Map<String, String>? query}) =>
      _request('DELETE', path, query: query);

  // ── SSE stream ──────────────────────────────────────────────────
  Stream<String> stream(String path) async* {
    final uri = _uri(path);
    final req = http.Request('GET', uri);
    final token = tokens.accessToken;
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.headers['Accept'] = 'text/event-stream';

    try {
      final resp = await _http.send(req);
      if (resp.statusCode != 200) {
        throw ApiException.fromStatus(resp.statusCode, 'Stream failed');
      }
      yield* resp.stream.transform(utf8.decoder);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(ApiErrorKind.network, 'Stream error: $e');
    }
  }

  // ── core ────────────────────────────────────────────────────────
  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    var response = await _send(method, path, body: body, query: query);

    if (response.statusCode == 401 && tokens.hasSession) {
      final ok = await _tryRefresh();
      if (ok) {
        response = await _send(method, path, body: body, query: query);
      } else {
        await _forceLogout();
        throw const ApiException(ApiErrorKind.unauthorized,
            'Session expired — please sign in again.');
      }
    }

    return _decode(response);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, query);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final encoded = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          return await _http.get(uri, headers: headers)
              .timeout(ApiConfig.requestTimeout);
        case 'POST':
          return await _http.post(uri, headers: headers, body: encoded)
              .timeout(ApiConfig.requestTimeout);
        case 'PATCH':
          return await _http.patch(uri, headers: headers, body: encoded)
              .timeout(ApiConfig.requestTimeout);
        case 'DELETE':
          return await _http.delete(uri, headers: headers, body: encoded)
              .timeout(ApiConfig.requestTimeout);
        default:
          throw ApiException(
              ApiErrorKind.unknown, 'Unsupported method: $method');
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(ApiErrorKind.network,
          'Request timed out. Check your connection.');
    } catch (e) {
      throw ApiException(ApiErrorKind.network, 'Network error: $e');
    }
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(ApiConfig.baseUrl);
    return base.replace(
      path: path,
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }

  // ── refresh ─────────────────────────────────────────────────────
  Future<bool> _tryRefresh() async {
    final refresh = tokens.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final resp = await _http
          .post(
            _uri('/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(ApiConfig.requestTimeout);

      if (resp.statusCode != 200) return false;

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final newAccess = body['access_token'] as String?;
      final newRefresh = body['refresh_token'] as String?;
      final userMap = body['user'] as Map<String, dynamic>?;
      final userId = userMap?['id'] as String?;

      if (newAccess == null || newRefresh == null || userId == null) {
        return false;
      }

      await tokens.save(
        access: newAccess,
        refresh: newRefresh,
        userId: userId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _forceLogout() async {
    await tokens.clear();
    onForceLogout?.call();
  }

  // ── decode ──────────────────────────────────────────────────────
  dynamic _decode(http.Response r) {
    final code = r.statusCode;

    if (r.body.isEmpty) {
      if (code >= 200 && code < 300) return null;
      throw ApiException.fromStatus(code, 'Empty response');
    }

    dynamic parsed;
    try {
      parsed = jsonDecode(r.body);
    } catch (_) {
      if (code >= 200 && code < 300) return r.body;
      throw ApiException.fromStatus(code, 'Invalid JSON response');
    }

    if (code >= 200 && code < 300) return parsed;

    // extract FastAPI detail
    String detail = 'Request failed (HTTP $code)';
    if (parsed is Map && parsed['detail'] != null) {
      final d = parsed['detail'];
      if (d is String) {
        detail = d;
      } else if (d is List && d.isNotEmpty) {
        final first = d.first;
        if (first is Map && first['msg'] != null) {
          detail = first['msg'].toString();
        }
      }
    }

    throw ApiException.fromStatus(code, detail);
  }

  void dispose() => _http.close();
}
