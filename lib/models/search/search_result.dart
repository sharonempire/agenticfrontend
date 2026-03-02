import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  const SearchResult({required this.id, required this.type, required this.title, this.subtitle, this.imageUrl, this.score, this.metadata = const {}});
  final String type;
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double? score;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [type, id];

  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
    id: '${j['id'] ?? ''}', type: j['type'] as String? ?? 'unknown',
    title: j['title'] as String? ?? '', subtitle: j['subtitle'] as String? ?? j['description'] as String?,
    imageUrl: j['image_url'] as String?, score: (j['score'] as num?)?.toDouble(),
    metadata: j['metadata'] as Map<String, dynamic>? ?? {},
  );
}

class SearchQuery extends Equatable {
  const SearchQuery({required this.query, this.types, this.page = 1, this.pageSize = 20});
  final String query;
  final List<String>? types;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [query, types, page, pageSize];

  Map<String, dynamic> toQueryParams() {
    final p = <String, dynamic>{'q': query, 'page': page, 'page_size': pageSize};
    if (types != null && types!.isNotEmpty) p['types'] = types!.join(',');
    return p;
  }
}
