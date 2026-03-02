class DashboardItem {
  const DashboardItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final DateTime? createdAt;
}
