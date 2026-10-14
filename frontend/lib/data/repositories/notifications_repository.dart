import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);
  final ApiClient _client;

  Future<Result<List<AppNotification>>> list({bool unreadOnly = false}) async {
    try {
      final data = await _client.get('/notifications', query: {
        if (unreadOnly) 'unread_only': 'true',
      });
      final items = ((data as Map<String, dynamic>)['items'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<void>> markRead(String id) async {
    try {
      await _client.post('/notifications/$id/read');
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<int>> markAllRead() async {
    try {
      final data = await _client.post('/notifications/read-all');
      return Ok(((data as Map<String, dynamic>)['count'] as num?)?.toInt() ?? 0);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Stream<String> stream() => _client.stream('/notifications/stream');
}
