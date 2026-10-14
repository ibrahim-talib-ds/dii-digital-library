import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/book.dart';
import '../models/paginated.dart';

class BooksRepository {
  BooksRepository(this._client);
  final ApiClient _client;

  Future<Result<Paginated<Book>>> list({
    String? search,
    String? categoryId,
    bool? availableOnly,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final data = await _client.get('/books', query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category': categoryId,
        if (availableOnly == true) 'available': 'true',
        'page': '$page',
        'size': '$size',
      });
      return Ok(Paginated.fromJson(
        data as Map<String, dynamic>,
        Book.fromJson,
      ));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Book>> get(String id) async {
    try {
      final data = await _client.get('/books/$id');
      return Ok(Book.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Book>> create(Map<String, dynamic> body) async {
    try {
      final data = await _client.post('/books', body: body);
      return Ok(Book.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Book>> update(String id, Map<String, dynamic> body) async {
    try {
      final data = await _client.patch('/books/$id', body: body);
      return Ok(Book.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await _client.delete('/books/$id');
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }
}
