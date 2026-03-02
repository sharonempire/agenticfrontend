import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    this.description,
    this.provider,
    this.imageUrl,
    this.category,
    this.duration,
    this.level,
    this.rating,
    this.reviewCount,
    this.price,
    this.currency,
    this.isFree = false,
    this.isEligible,
    this.tags = const [],
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? provider;
  final String? imageUrl;
  final String? category;
  final String? duration;
  final String? level;
  final double? rating;
  final int? reviewCount;
  final double? price;
  final String? currency;
  final bool isFree;
  final bool? isEligible;
  final List<String> tags;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id];

  /// Parse from FastAPI JSON.
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: '${json['id'] ?? json['course_id'] ?? ''}',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      provider: json['provider'] as String? ?? json['institution'] as String?,
      imageUrl: json['image_url'] as String? ?? json['thumbnail'] as String?,
      category: json['category'] as String?,
      duration: json['duration'] as String?,
      level: json['level'] as String? ?? json['difficulty'] as String?,
      rating: _toDouble(json['rating']),
      reviewCount: json['review_count'] as int? ?? json['reviews'] as int?,
      price: _toDouble(json['price']),
      currency: json['currency'] as String?,
      isFree: json['is_free'] as bool? ?? ((_toDouble(json['price']) ?? 0) == 0),
      isEligible: json['is_eligible'] as bool?,
      tags: _toStringList(json['tags']),
      url: json['url'] as String? ?? json['link'] as String?,
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }

  /// Parse from Supabase row (column names may differ).
  factory Course.fromSupabase(Map<String, dynamic> row) {
    return Course(
      id: '${row['id'] ?? ''}',
      title: row['title'] as String? ?? '',
      description: row['description'] as String?,
      provider: row['provider'] as String?,
      imageUrl: row['image_url'] as String?,
      category: row['category'] as String?,
      duration: row['duration'] as String?,
      level: row['level'] as String?,
      rating: _toDouble(row['rating']),
      reviewCount: row['review_count'] as int?,
      price: _toDouble(row['price']),
      currency: row['currency'] as String?,
      isFree: row['is_free'] as bool? ?? false,
      isEligible: row['is_eligible'] as bool?,
      tags: _toStringList(row['tags']),
      url: row['url'] as String?,
      createdAt: _tryParseDate(row['created_at']),
      updatedAt: _tryParseDate(row['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'provider': provider,
        'image_url': imageUrl,
        'category': category,
        'duration': duration,
        'level': level,
        'rating': rating,
        'review_count': reviewCount,
        'price': price,
        'currency': currency,
        'is_free': isFree,
        'is_eligible': isEligible,
        'tags': tags,
        'url': url,
      };
}

class CourseFilter extends Equatable {
  const CourseFilter({
    this.query,
    this.category,
    this.level,
    this.isFree,
    this.minRating,
    this.provider,
    this.tags,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? query;
  final String? category;
  final String? level;
  final bool? isFree;
  final double? minRating;
  final String? provider;
  final List<String>? tags;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props =>
      [query, category, level, isFree, minRating, provider, tags, page, pageSize];

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (query != null && query!.isNotEmpty) params['q'] = query;
    if (category != null) params['category'] = category;
    if (level != null) params['level'] = level;
    if (isFree != null) params['is_free'] = isFree;
    if (minRating != null) params['min_rating'] = minRating;
    if (provider != null) params['provider'] = provider;
    if (tags != null && tags!.isNotEmpty) params['tags'] = tags!.join(',');
    return params;
  }
}

// ── Helpers ──

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

List<String> _toStringList(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => '$e').toList();
  if (v is String) return v.split(',').map((e) => e.trim()).toList();
  return [];
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
