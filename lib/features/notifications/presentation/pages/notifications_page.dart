import 'package:flutter/material.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.notifications, style: AppTypography.headline)),
      body: EmptyState(svgPath: AppImages.emptyNotifications, title: 'No notifications', subtitle: 'You\'re all caught up!'),
    );
  }
}
