import '../../core/result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/category.dart';

class CategoriesRepository {
  CategoriesRepository(this._client);
  final ApiClient _client;

  Future<Result<List<Category>>> list({bool includeInactive = false}) async {
    try {
      final data = await _client.get('/categories', query: {
        if (includeInactive) 'include_inactive': 'true',
      });
      final items = (data as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiException(ApiErrorKind.unknown, e.toString()));
    }
  }
}
