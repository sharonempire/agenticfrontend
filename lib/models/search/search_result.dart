import 'package:equatable/equatable.dart';

/// Unified search result from /api/v1/search/*.
class SearchResult extends Equatable {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.score,
    this.metadata = const {},
  });

  /// "course", "job", "lead", etc.
  final String type;
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double? score;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [type, id];

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: '${json['id'] ?? ''}',
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

class SearchQuery extends Equatable {
  const SearchQuery({
    required this.query,
    this.types,
    this.page = 1,
    this.pageSize = 20,
  });

  final String query;
  final List<String>? types; // filter by result type
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [query, types, page, pageSize];

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'q': query,
      'page': page,
      'page_size': pageSize,
    };
    if (types != null && types!.isNotEmpty) params['types'] = types!.join(',');
    return params;
  }
}
