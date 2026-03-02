import '../../domain/entities/dashboard_item.dart';

class DashboardItemModel extends DashboardItem {
  const DashboardItemModel({
    required super.id,
    required super.title,
    super.subtitle,
    super.description,
    super.createdAt,
  });

  factory DashboardItemModel.fromJson(Map<String, dynamic> json) {
    final id =
        _asString(json['id']) ??
        _asString(json['item_id']) ??
        _asString(json['uuid']) ??
        '';
    final title =
        _asString(json['title']) ??
        _asString(json['name']) ??
        _asString(json['label']) ??
        'Untitled';
    final subtitle =
        _asString(json['subtitle']) ??
        _asString(json['category']) ??
        _asString(json['status']);
    final description =
        _asString(json['description']) ?? _asString(json['summary']);

    final createdAtRaw = json['created_at'] ?? json['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is String && createdAtRaw.trim().isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    return DashboardItemModel(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      createdAt: createdAt,
    );
  }

  static String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num) {
      return value.toString();
    }
    return null;
  }
}
