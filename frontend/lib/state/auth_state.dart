import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../data/api/api_exception.dart';
import '../data/api/token_store.dart';
import '../data/models/enums.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  AuthState({
    required AuthRepository repo,
    required TokenStore tokens,
  })  : _repo = repo,
        _tokens = tokens;

  final AuthRepository _repo;
  final TokenStore _tokens;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User?      get user   => _user;
  String?    get error  => _error;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isReady         => _status != AuthStatus.unknown;
  bool get isStudent       => _user?.role == UserRole.student;
  bool get isStaff         => _user?.isStaff ?? false;
  bool get isAdmin         => _user?.role == UserRole.admin;

  // ── bootstrap: try restore from stored refresh token ────────────
  Future<void> bootstrap() async {
    await _tokens.load();
    final restored = await _repo.restoreSession();
    if (restored == null) {
      _setUnauthenticated();
      return;
    }
    switch (restored) {
      case Ok(:final data):
        _setAuthenticated(data);
      case Err(:final error):
        _error = _friendly(error);
        _setUnauthenticated();
    }
  }

  // ── login ───────────────────────────────────────────────────────
  Future<bool> login({
    required String studentNumber,
    required String password,
  }) async {
    _error = null;
    notifyListeners();

    final res = await _repo.login(
      studentNumber: studentNumber,
      password: password,
    );
    return _handleAuthResult(res);
  }

  // ── signup ──────────────────────────────────────────────────────
  Future<bool> signup({
    required String studentNumber,
    required String name,
    required String password,
    String? department,
    int? year,
  }) async {
    _error = null;
    notifyListeners();

    final res = await _repo.signup(
      studentNumber: studentNumber,
      name: name,
      password: password,
      department: department,
      year: year,
    );
    return _handleAuthResult(res);
  }

  // ── logout ──────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _setUnauthenticated();
  }

  // ── called by ApiClient when refresh fails ──────────────────────
  void onForceLogout() {
    _setUnauthenticated();
  }

  // ── update local user after profile edit ────────────────────────
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // ── internal ────────────────────────────────────────────────────
  bool _handleAuthResult(Result<User> res) {
    switch (res) {
      case Ok(:final data):
        _error = null;
        _setAuthenticated(data);
        return true;
      case Err(:final error):
        _error = _friendly(error);
        _setUnauthenticated();
        return false;
    }
  }

  void _setAuthenticated(User user) {
    _user = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _friendly(Object e) {
    if (e is ApiException) return e.friendlyMessage;
    return e.toString();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
