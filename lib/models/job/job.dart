import 'package:equatable/equatable.dart';

class Job extends Equatable {
  const Job({
    required this.id,
    required this.title,
    this.company,
    this.companyLogo,
    this.location,
    this.isRemote = false,
    this.type,
    this.salary,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    this.description,
    this.requirements = const [],
    this.skills = const [],
    this.category,
    this.experienceLevel,
    this.postedAt,
    this.expiresAt,
    this.url,
    this.isSaved = false,
    this.isApplied = false,
    this.applicationStatus,
  });

  final String id;
  final String title;
  final String? company;
  final String? companyLogo;
  final String? location;
  final bool isRemote;
  final String? type; // full-time, part-time, contract, internship
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
  final DateTime? expiresAt;
  final String? url;
  final bool isSaved;
  final bool isApplied;
  final String? applicationStatus;

  @override
  List<Object?> get props => [id];

  Job copyWith({
    bool? isSaved,
    bool? isApplied,
    String? applicationStatus,
  }) {
    return Job(
      id: id,
      title: title,
      company: company,
      companyLogo: companyLogo,
      location: location,
      isRemote: isRemote,
      type: type,
      salary: salary,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      currency: currency,
      description: description,
      requirements: requirements,
      skills: skills,
      category: category,
      experienceLevel: experienceLevel,
      postedAt: postedAt,
      expiresAt: expiresAt,
      url: url,
      isSaved: isSaved ?? this.isSaved,
      isApplied: isApplied ?? this.isApplied,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: '${json['id'] ?? json['job_id'] ?? ''}',
      title: json['title'] as String? ?? json['job_title'] as String? ?? '',
      company: json['company'] as String? ?? json['company_name'] as String?,
      companyLogo: json['company_logo'] as String? ?? json['logo_url'] as String?,
      location: json['location'] as String?,
      isRemote: json['is_remote'] as bool? ?? false,
      type: json['type'] as String? ?? json['job_type'] as String?,
      salary: json['salary'] as String?,
      salaryMin: _toDouble(json['salary_min']),
      salaryMax: _toDouble(json['salary_max']),
      currency: json['currency'] as String?,
      description: json['description'] as String?,
      requirements: _toStringList(json['requirements']),
      skills: _toStringList(json['skills']),
      category: json['category'] as String?,
      experienceLevel: json['experience_level'] as String? ?? json['level'] as String?,
      postedAt: _tryParseDate(json['posted_at'] ?? json['created_at']),
      expiresAt: _tryParseDate(json['expires_at']),
      url: json['url'] as String? ?? json['apply_url'] as String?,
      isSaved: json['is_saved'] as bool? ?? false,
      isApplied: json['is_applied'] as bool? ?? false,
      applicationStatus: json['application_status'] as String?,
    );
  }

  factory Job.fromSupabase(Map<String, dynamic> row) {
    return Job(
      id: '${row['id'] ?? ''}',
      title: row['title'] as String? ?? '',
      company: row['company'] as String?,
      companyLogo: row['company_logo'] as String?,
      location: row['location'] as String?,
      isRemote: row['is_remote'] as bool? ?? false,
      type: row['type'] as String?,
      salary: row['salary'] as String?,
      salaryMin: _toDouble(row['salary_min']),
      salaryMax: _toDouble(row['salary_max']),
      currency: row['currency'] as String?,
      description: row['description'] as String?,
      requirements: _toStringList(row['requirements']),
      skills: _toStringList(row['skills']),
      category: row['category'] as String?,
      experienceLevel: row['experience_level'] as String?,
      postedAt: _tryParseDate(row['posted_at'] ?? row['created_at']),
      expiresAt: _tryParseDate(row['expires_at']),
      url: row['url'] as String?,
      isSaved: row['is_saved'] as bool? ?? false,
      isApplied: row['is_applied'] as bool? ?? false,
      applicationStatus: row['application_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'company_logo': companyLogo,
        'location': location,
        'is_remote': isRemote,
        'type': type,
        'salary': salary,
        'salary_min': salaryMin,
        'salary_max': salaryMax,
        'currency': currency,
        'description': description,
        'requirements': requirements,
        'skills': skills,
        'category': category,
        'experience_level': experienceLevel,
        'url': url,
      };
}

class JobFilter extends Equatable {
  const JobFilter({
    this.query,
    this.category,
    this.type,
    this.location,
    this.isRemote,
    this.experienceLevel,
    this.salaryMin,
    this.skills,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? query;
  final String? category;
  final String? type;
  final String? location;
  final bool? isRemote;
  final String? experienceLevel;
  final double? salaryMin;
  final List<String>? skills;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props =>
      [query, category, type, location, isRemote, experienceLevel, salaryMin, skills, page, pageSize];

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (query != null && query!.isNotEmpty) params['q'] = query;
    if (category != null) params['category'] = category;
    if (type != null) params['type'] = type;
    if (location != null) params['location'] = location;
    if (isRemote != null) params['is_remote'] = isRemote;
    if (experienceLevel != null) params['experience_level'] = experienceLevel;
    if (salaryMin != null) params['salary_min'] = salaryMin;
    if (skills != null && skills!.isNotEmpty) params['skills'] = skills!.join(',');
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
