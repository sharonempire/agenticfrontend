import 'package:logger/logger.dart';

import '../../config/backend_mode.dart';
import '../../config/feature_flags.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/fallback_helper.dart';
import '../../models/common/paginated_response.dart';
import '../../models/search/search_result.dart';
import '../search_repository.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Compatibility adapter for unified search.
class SearchRepositoryCompat implements SearchRepository {
  SearchRepositoryCompat({
    required this.fastApi,
    required this.supabase,
    required this.mode,
  });

  final SearchRepository fastApi;
  final SearchRepository supabase;
  final BackendMode mode;

  BackendMode get _effectiveMode =>
      FeatureFlags.searchFastApi ? mode : BackendMode.supabaseOnly;

  @override
  Future<PaginatedResponse<SearchResult>> search(SearchQuery query) async {
    final effective = _effectiveMode;

    if (effective == BackendMode.supabaseOnly) {
      return supabase.search(query);
    }

    try {
      return await fastApi.search(query);
    } on AppException catch (e) {
      if (shouldFallback(e, effective)) {
        logFallback('SearchRepo', 'search', e);
        return supabase.search(query);
      }
      rethrow;
    } catch (e) {
      if (effective == BackendMode.fastapiPreferred) {
        _log.w('[SearchRepo.search] Unexpected error ($e), falling back to Supabase');
        return supabase.search(query);
      }
      rethrow;
    }
  }
}
