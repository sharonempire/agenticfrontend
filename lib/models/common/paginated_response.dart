class PaginatedResponse<T> {
  const PaginatedResponse({required this.items, required this.total, required this.page, required this.pageSize});
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total && total > 0;

  PaginatedResponse<R> map<R>(R Function(T) transform) => PaginatedResponse<R>(
    items: items.map(transform).toList(), total: total, page: page, pageSize: pageSize,
  );

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromItem) {
    final rawItems = json['items'] as List? ?? json['results'] as List? ?? json['data'] as List? ?? [];
    return PaginatedResponse<T>(
      items: rawItems.cast<Map<String, dynamic>>().map(fromItem).toList(),
      total: json['total'] as int? ?? json['count'] as int? ?? rawItems.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? rawItems.length,
    );
  }
}
