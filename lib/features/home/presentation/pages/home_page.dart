import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppStrings.home, style: AppTypography.largeTitle),
            actions: [
              IconButton(icon: const Icon(AppIcons.notification), onPressed: () => context.push(AppRoutes.notifications)),
            ],
          ),
          SliverPadding(
            padding: AppSpacing.pagePadding,
            sliver: SliverList.list(children: [
              _SectionHeader(title: 'Recommended Courses', onSeeAll: () => context.go(AppRoutes.courses)),
              const SizedBox(height: AppSpacing.sm),
              Container(height: 180, decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg, boxShadow: AppShadows.card), child: Center(child: Text('Course cards load here', style: AppTypography.footnote))),
              const SizedBox(height: AppSpacing.sectionGap),
              _SectionHeader(title: 'Latest Jobs', onSeeAll: () => context.go(AppRoutes.jobs)),
              const SizedBox(height: AppSpacing.sm),
              Container(height: 180, decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg, boxShadow: AppShadows.card), child: Center(child: Text('Job cards load here', style: AppTypography.footnote))),
              const SizedBox(height: AppSpacing.sectionGap),
              _SectionHeader(title: 'AI Copilot', onSeeAll: () => context.go(AppRoutes.aiCopilot)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadius.lg),
                child: Row(children: [
                  const Icon(AppIcons.sparkle, color: AppColors.textInverse, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Smart Recommendations', style: AppTypography.headline.copyWith(color: AppColors.textInverse)),
                    const SizedBox(height: 4),
                    Text('Get AI-powered course and job suggestions', style: AppTypography.footnote.copyWith(color: AppColors.textInverse.withValues(alpha: 0.8))),
                  ])),
                ]),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.title3),
        if (onSeeAll != null) GestureDetector(onTap: onSeeAll, child: Text(AppStrings.seeAll, style: AppTypography.subheadline.copyWith(color: AppColors.textLink))),
      ],
    );
  }
}
