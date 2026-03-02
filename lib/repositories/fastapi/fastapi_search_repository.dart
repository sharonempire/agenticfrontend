import '../../core/error/app_exception.dart';
import '../../core/network/fastapi_client.dart';
import '../../models/common/paginated_response.dart';
import '../../models/search/search_result.dart';
import '../search_repository.dart';

/// FastAPI-backed unified search.
/// Maps /api/v1/search/* endpoints.
class FastApiSearchRepository implements SearchRepository {
  FastApiSearchRepository({required this.client});

  final FastApiClient client;

  @override
  Future<PaginatedResponse<SearchResult>> search(SearchQuery query) async {
    final response = await client.get<Map<String, dynamic>>(
      '/search/',
      queryParameters: query.toQueryParams(),
    );

    final data = response.data;
    if (data == null) {
      throw const ParseException('Empty search response');
    }

    if (data.containsKey('items')) {
      return PaginatedResponse.fromJson(data, SearchResult.fromJson);
    }

    if (data.containsKey('results')) {
      final items = (data['results'] as List)
          .cast<Map<String, dynamic>>()
          .map(SearchResult.fromJson)
          .toList();
      return PaginatedResponse<SearchResult>(
        items: items,
        total: data['total'] as int? ?? items.length,
        page: data['page'] as int? ?? query.page,
        pageSize: data['page_size'] as int? ?? query.pageSize,
      );
    }

    throw const ParseException('Unable to parse search response');
  }
}
