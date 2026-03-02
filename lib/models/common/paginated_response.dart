/// Generic paginated response wrapper.
/// Maps both FastAPI paginated payloads and Supabase range-based results.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => (page * pageSize) < total;
  int get totalPages => (total / pageSize).ceil();

  PaginatedResponse<R> map<R>(R Function(T) transform) {
    return PaginatedResponse<R>(
      items: items.map(transform).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Parse from FastAPI's standard paginated envelope:
  /// { "items": [...], "total": N, "page": N, "page_size": N }
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItemJson,
  ) {
    final rawItems = json['items'] as List? ?? [];
    return PaginatedResponse<T>(
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(fromItemJson)
          .toList(),
      total: json['total'] as int? ?? rawItems.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? rawItems.length,
    );
  }
}
