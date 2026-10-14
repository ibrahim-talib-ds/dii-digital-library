import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/report_summary.dart';

class ReportsRepository {
  ReportsRepository(this._client);
  final ApiClient _client;

  Future<Result<ReportSummary>> summary() async {
    try {
      final data = await _client.get('/reports/summary');
      return Ok(ReportSummary.fromJson(data as Map<String, dynamic>));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<List<OverdueRow>>> overdue() async {
    try {
      final data = await _client.get('/reports/overdue');
      final items = ((data as Map<String, dynamic>)['items'] as List<dynamic>)
          .map((e) => OverdueRow.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }

  Future<Result<List<PopularBook>>> popular({int limit = 10}) async {
    try {
      final data = await _client.get('/reports/popular', query: {'limit': '$limit'});
      final items = ((data as Map<String, dynamic>)['items'] as List<dynamic>)
          .map((e) => PopularBook.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }
}
