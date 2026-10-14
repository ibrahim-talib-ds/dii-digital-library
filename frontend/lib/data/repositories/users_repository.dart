import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/user.dart';
import '../models/paginated.dart';

class UsersRepository {
  UsersRepository(this._client);
  final ApiClient _client;

  Future<Result<Paginated<User>>> list({
    String? role,
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final data = await _client.get('/users', query: {
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': '$page',
        'size': '$size',
      });
      return Ok(Paginated.fromJson(
        data as Map<String, dynamic>,
        User.fromJson,
      ));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<User>> get(String id) async {
    try {
      final data = await _client.get('/users/$id');
      return Ok(User.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<User>> update(String id, Map<String, dynamic> body) async {
    try {
      final data = await _client.patch('/users/$id', body: body);
      return Ok(User.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Send an in-app notification message to a user.
  Future<Result<void>> sendMessage(
    String userId, {
    required String title,
    required String body,
  }) async {
    try {
      await _client.post('/users/$userId/message', body: {
        'title': title,
        'body': body,
      });
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<User>> block(String id) async {
    try {
      final data = await _client.post('/users/$id/block');
      return Ok(User.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<User>> unblock(String id) async {
    try {
      final data = await _client.post('/users/$id/unblock');
      return Ok(User.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }
}
