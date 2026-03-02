import 'package:equatable/equatable.dart';

class Job extends Equatable {
  const Job({
    required this.id, required this.title, this.company, this.companyLogo,
    this.location, this.isRemote = false, this.type, this.salary,
    this.salaryMin, this.salaryMax, this.currency, this.description,
    this.requirements = const [], this.skills = const [],
    this.category, this.experienceLevel, this.postedAt, this.url,
    this.isSaved = false, this.isApplied = false, this.applicationStatus,
  });

  final String id;
  final String title;
  final String? company;
  final String? companyLogo;
  final String? location;
  final bool isRemote;
  final String? type;
  final String? salary;
  final double? salaryMin;
  final double? salaryMax;
  final String? currency;
  final String? description;
  final List<String> requirements;
  final List<String> skills;
  final String? category;
  final String? experienceLevel;
  final DateTime? postedAt;
  final String? url;
  final bool isSaved;
  final bool isApplied;
  final String? applicationStatus;

  @override
  List<Object?> get props => [id];

  Job copyWith({bool? isSaved, bool? isApplied, String? applicationStatus}) => Job(
    id: id, title: title, company: company, companyLogo: companyLogo,
    location: location, isRemote: isRemote, type: type, salary: salary,
    salaryMin: salaryMin, salaryMax: salaryMax, currency: currency,
    description: description, requirements: requirements, skills: skills,
    category: category, experienceLevel: experienceLevel, postedAt: postedAt,
    url: url,
    isSaved: isSaved ?? this.isSaved,
    isApplied: isApplied ?? this.isApplied,
    applicationStatus: applicationStatus ?? this.applicationStatus,
  );

  factory Job.fromJson(Map<String, dynamic> j) => Job(
    id: '${j['id'] ?? j['job_id'] ?? ''}',
    title: j['title'] as String? ?? j['job_title'] as String? ?? '',
    company: j['company'] as String? ?? j['company_name'] as String?,
    companyLogo: j['company_logo'] as String? ?? j['logo_url'] as String?,
    location: j['location'] as String?,
    isRemote: j['is_remote'] as bool? ?? false,
    type: j['type'] as String? ?? j['job_type'] as String?,
    salary: j['salary'] as String?,
    salaryMin: _d(j['salary_min']),
    salaryMax: _d(j['salary_max']),
    currency: j['currency'] as String?,
    description: j['description'] as String?,
    requirements: _sl(j['requirements']),
    skills: _sl(j['skills']),
    category: j['category'] as String?,
    experienceLevel: j['experience_level'] as String? ?? j['level'] as String?,
    postedAt: _dt(j['posted_at'] ?? j['created_at']),
    url: j['url'] as String? ?? j['apply_url'] as String?,
    isSaved: j['is_saved'] as bool? ?? false,
    isApplied: j['is_applied'] as bool? ?? false,
    applicationStatus: j['application_status'] as String?,
  );

  factory Job.fromSupabase(Map<String, dynamic> r) => Job.fromJson(r);
}

class JobFilter extends Equatable {
  const JobFilter({this.query, this.category, this.type, this.location, this.isRemote, this.experienceLevel, this.page = 1, this.pageSize = 20});
  final String? query;
  final String? category;
  final String? type;
  final String? location;
  final bool? isRemote;
  final String? experienceLevel;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [query, category, type, location, isRemote, experienceLevel, page, pageSize];

  Map<String, dynamic> toQueryParams() {
    final p = <String, dynamic>{'page': page, 'page_size': pageSize};
    if (query != null && query!.isNotEmpty) p['q'] = query;
    if (category != null) p['category'] = category;
    if (type != null) p['type'] = type;
    if (location != null) p['location'] = location;
    if (isRemote != null) p['is_remote'] = isRemote;
    if (experienceLevel != null) p['experience_level'] = experienceLevel;
    return p;
  }
}

double? _d(dynamic v) { if (v is double) return v; if (v is int) return v.toDouble(); if (v is String) return double.tryParse(v); return null; }
List<String> _sl(dynamic v) { if (v is List) return v.map((e) => '$e').toList(); return []; }
DateTime? _dt(dynamic v) { if (v is DateTime) return v; if (v is String) return DateTime.tryParse(v); return null; }
