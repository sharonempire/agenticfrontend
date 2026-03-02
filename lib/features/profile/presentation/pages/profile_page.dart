import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(AppStrings.profile, style: AppTypography.largeTitle)),
          SliverPadding(
            padding: AppSpacing.pagePadding,
            sliver: SliverList.list(children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg, boxShadow: AppShadows.card),
                child: Row(children: [
                  CircleAvatar(radius: 32, backgroundColor: AppColors.chipBg(AppColors.primary), child: const Icon(AppIcons.person, size: 32, color: AppColors.primary)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Student Name', style: AppTypography.title3),
                    Text('student@email.com', style: AppTypography.footnote),
                  ])),
                ]),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _MenuItem(icon: AppIcons.bookmarkSystem, title: AppStrings.savedJobs, onTap: () => context.go('${AppRoutes.jobs}/${AppRoutes.savedJobs}')),
              _MenuItem(icon: AppIcons.checkmark, title: AppStrings.appliedJobs, onTap: () => context.go('${AppRoutes.jobs}/${AppRoutes.appliedJobs}')),
              _MenuItem(icon: AppIcons.notification, title: AppStrings.notifications, onTap: () => context.push(AppRoutes.notifications)),
              _MenuItem(icon: AppIcons.settingsIcon, title: AppStrings.settings, onTap: () => context.go('${AppRoutes.profile}/${AppRoutes.settings}')),
              const SizedBox(height: AppSpacing.lg),
              _MenuItem(icon: AppIcons.logout, title: 'Log Out', color: AppColors.error, onTap: () => context.go(AppRoutes.login)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.title, required this.onTap, this.color});
  final IconData icon; final String title; final VoidCallback onTap; final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        leading: Icon(icon, color: c, size: 22),
        title: Text(title, style: AppTypography.body.copyWith(color: c)),
        trailing: const Icon(AppIcons.forward, size: 16, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        tileColor: AppColors.surface,
      ),
    );
  }
}
