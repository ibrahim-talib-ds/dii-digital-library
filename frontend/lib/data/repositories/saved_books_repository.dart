import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/book.dart';

class SavedBooksRepository {
  SavedBooksRepository(this._client);
  final ApiClient _client;

  Future<Result<List<Book>>> list() async {
    try {
      final data = await _client.get('/books/saved/list');
      final items = (data as List<dynamic>)
          .map((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<void>> save(String bookId) async {
    try {
      await _client.post('/books/$bookId/save');
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<void>> unsave(String bookId) async {
    try {
      await _client.delete('/books/$bookId/save');
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }
}
