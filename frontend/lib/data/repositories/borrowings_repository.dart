import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/borrowing.dart';

class BorrowingsRepository {
  BorrowingsRepository(this._client);
  Future<Result<void>> remind(String id) async {
    try {
      await _client.post('/borrowings/$id/remind');
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Borrowing>> issue({
    required String studentNumber,
    required String bookCode,
    required int days,
    String? notes,
  }) async {
    try {
      final data = await _client.post('/borrowings/issue', body: {
        'student_number': studentNumber,
        'book_code': bookCode,
        'days': days,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return Ok(Borrowing.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  final ApiClient _client;

  /// Student: request a book.
  Future<Result<Borrowing>> request({
    required String bookId,
    String? notes,
  }) async {
    try {
      final data = await _client.post('/borrowings', body: {
        'book_id': bookId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return Ok(Borrowing.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Student: my borrowings.
  Future<Result<List<Borrowing>>> mine() async {
    try {
      final data = await _client.get('/borrowings/mine');
      final items = (data as List<dynamic>)
          .map((e) => Borrowing.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  /// Staff: list with filters.
  Future<Result<List<Borrowing>>> listForStaff({String? status}) async {
    try {
      final data = await _client.get('/borrowings', query: {
        if (status != null) 'status': status,
      });
      final items = ((data as Map<String, dynamic>)['items'] as List<dynamic>)
          .map((e) => Borrowing.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Borrowing>> approve(String id, {required int days}) async {
    try {
      final data = await _client.post(
        '/borrowings/$id/approve',
        body: {'days': days},
      );
      return Ok(Borrowing.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Borrowing>> reject(String id) async {
    try {
      final data = await _client.post('/borrowings/$id/reject');
      return Ok(Borrowing.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<Borrowing>> markReturned(String id) async {
    try {
      final data = await _client.post('/borrowings/$id/return');
      return Ok(Borrowing.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }
}
