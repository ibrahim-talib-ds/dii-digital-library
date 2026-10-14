import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';

/// Persists access + refresh tokens.
/// - Web → localStorage (via shared_preferences_web)
/// - Mobile → native preferences
class TokenStore {
  String? _access;
  String? _refresh;
  String? _userId;

  String? get accessToken  => _access;
  String? get refreshToken => _refresh;
  String? get userId       => _userId;

  bool get hasSession => (_refresh ?? '').isNotEmpty;

  /// Load tokens from disk. Call once at boot.
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _access  = p.getString(DiiStorage.accessToken);
    _refresh = p.getString(DiiStorage.refreshToken);
    _userId  = p.getString(DiiStorage.userId);
  }

  /// Save after successful login/signup/refresh.
  Future<void> save({
    required String access,
    required String refresh,
    String? userId,
  }) async {
    _access = access;
    _refresh = refresh;
    if (userId != null) _userId = userId;

    final p = await SharedPreferences.getInstance();
    await p.setString(DiiStorage.accessToken, access);
    await p.setString(DiiStorage.refreshToken, refresh);
    if (userId != null) await p.setString(DiiStorage.userId, userId);
  }

  /// Clear on logout.
  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _userId = null;

    final p = await SharedPreferences.getInstance();
    await p.remove(DiiStorage.accessToken);
    await p.remove(DiiStorage.refreshToken);
    await p.remove(DiiStorage.userId);
  }
}
