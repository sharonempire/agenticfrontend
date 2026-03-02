import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.id, required this.title, this.description, this.provider,
    this.imageUrl, this.category, this.duration, this.level, this.rating,
    this.reviewCount, this.price, this.currency, this.isFree = false,
    this.isEligible, this.tags = const [], this.url, this.createdAt,
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

  @override
  List<Object?> get props => [id];

  factory Course.fromJson(Map<String, dynamic> j) => Course(
    id: '${j['id'] ?? j['course_id'] ?? ''}',
    title: j['title'] as String? ?? j['name'] as String? ?? '',
    description: j['description'] as String?,
    provider: j['provider'] as String? ?? j['institution'] as String?,
    imageUrl: j['image_url'] as String? ?? j['thumbnail'] as String?,
    category: j['category'] as String?,
    duration: j['duration'] as String?,
    level: j['level'] as String? ?? j['difficulty'] as String?,
    rating: _d(j['rating']),
    reviewCount: j['review_count'] as int? ?? j['reviews'] as int?,
    price: _d(j['price']),
    currency: j['currency'] as String?,
    isFree: j['is_free'] as bool? ?? ((_d(j['price']) ?? 0) == 0),
    isEligible: j['is_eligible'] as bool?,
    tags: _sl(j['tags']),
    url: j['url'] as String? ?? j['link'] as String?,
    createdAt: _dt(j['created_at']),
  );

  factory Course.fromSupabase(Map<String, dynamic> r) => Course.fromJson(r);
}

class CourseFilter extends Equatable {
  const CourseFilter({this.query, this.category, this.level, this.isFree, this.provider, this.page = 1, this.pageSize = 20});
  final String? query;
  final String? category;
  final String? level;
  final bool? isFree;
  final String? provider;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [query, category, level, isFree, provider, page, pageSize];

  Map<String, dynamic> toQueryParams() {
    final p = <String, dynamic>{'page': page, 'page_size': pageSize};
    if (query != null && query!.isNotEmpty) p['q'] = query;
    if (category != null) p['category'] = category;
    if (level != null) p['level'] = level;
    if (isFree != null) p['is_free'] = isFree;
    if (provider != null) p['provider'] = provider;
    return p;
  }
}

double? _d(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
List<String> _sl(dynamic v) {
  if (v is List) return v.map((e) => '$e').toList();
  if (v is String) return v.split(',').map((e) => e.trim()).toList();
  return [];
}
DateTime? _dt(dynamic v) {
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
