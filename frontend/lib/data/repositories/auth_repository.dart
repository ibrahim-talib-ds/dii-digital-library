import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/token_store.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this._client, this._tokens);

  final ApiClient _client;
  final TokenStore _tokens;

  /// Sign up a new student (student_number, name, password).
  Future<Result<User>> signup({
    required String studentNumber,
    required String name,
    required String password,
    String? department,
    int? year,
  }) async {
    try {
      final data = await _client.post('/auth/signup', body: {
        'student_number': studentNumber,
        'name': name,
        'password': password,
        if (department != null) 'department': department,
        if (year != null) 'year': year,
      });
      return await _storeAndReturnUser(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Look up a student in the roster by student number.
  /// Returns a map with { student_number, name, email, department, year, has_account }
  Future<Result<Map<String, dynamic>>> lookupRoster(String studentNumber) async {
    try {
      final data = await _client.get('/auth/roster/$studentNumber');
      return Ok(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(
        ApiErrorKind.network,
        'Could not reach server. Check your connection.',
      ));
    }
  }

  /// Librarian self-signup (no admin needed).
  Future<Result<User>> librarianSignup({
    required String staffNumber,
    required String name,
    required String password,
    String? department,
  }) async {
    try {
      final data = await _client.post('/auth/librarian-signup', body: {
        'staff_number': staffNumber,
        'name': name,
        'password': password,
        if (department != null) 'department': department,
      });
      return await _storeAndReturnUser(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Log in with student_number + password.
  Future<Result<User>> login({
    required String studentNumber,
    required String password,
  }) async {
    try {
      final data = await _client.post('/auth/login', body: {
        'student_number': studentNumber,
        'password': password,
      });
      return await _storeAndReturnUser(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Try to restore the session from a stored refresh token.
  /// Returns null if no session, Err if refresh fails.
  Future<Result<User>?> restoreSession() async {
    if (!_tokens.hasSession) return null;
    try {
      final data = await _client.post('/auth/refresh', body: {
        'refresh_token': _tokens.refreshToken,
      });
      return await _storeAndReturnUser(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      await _tokens.clear();
      return Err(e);
    } catch (e) {
      await _tokens.clear();
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Logout — invalidate the refresh token server-side, clear local tokens.
  Future<void> logout() async {
    final refresh = _tokens.refreshToken;
    try {
      if (refresh != null) {
        await _client.post('/auth/logout', body: {'refresh_token': refresh});
      }
    } catch (_) {
      // best-effort; local clear is the important part
    } finally {
      await _tokens.clear();
    }
  }

  // ── helpers ─────────────────────────────────────────────────────
  Future<Result<User>> _storeAndReturnUser(Map<String, dynamic> data) async {
    final access  = data['access_token'] as String;
    final refresh = data['refresh_token'] as String;
    final user    = User.fromJson(data['user'] as Map<String, dynamic>);

    await _tokens.save(
      access: access,
      refresh: refresh,
      userId: user.id,
    );
    return Ok(user);
  }
}
