import '../models/common/paginated_response.dart';
import '../models/search/search_result.dart';

/// Abstract contract for unified search.
abstract class SearchRepository {
  Future<PaginatedResponse<SearchResult>> search(SearchQuery query);
}
