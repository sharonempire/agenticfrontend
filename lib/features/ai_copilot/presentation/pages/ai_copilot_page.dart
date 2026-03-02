import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class AiCopilotPage extends StatelessWidget {
  const AiCopilotPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(AppStrings.aiCopilot, style: AppTypography.largeTitle)),
          SliverPadding(
            padding: AppSpacing.pagePadding,
            sliver: SliverList.list(children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadius.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(AppIcons.sparkle, color: AppColors.textInverse, size: 40),
                  const SizedBox(height: AppSpacing.md),
                  Text('Your AI Assistant', style: AppTypography.title2.copyWith(color: AppColors.textInverse)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Get personalized recommendations, lead scoring, and smart actions powered by AI.', style: AppTypography.subheadline.copyWith(color: AppColors.textInverse.withValues(alpha: 0.8))),
                ]),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('Quick Actions', style: AppTypography.title3),
              const SizedBox(height: AppSpacing.md),
              _ActionTile(icon: AppIcons.sparkle, title: 'Get Recommendations', subtitle: 'AI-powered course & job suggestions'),
              const SizedBox(height: AppSpacing.listItemGap),
              _ActionTile(icon: AppIcons.mail, title: 'Draft Email', subtitle: 'Generate professional emails'),
              const SizedBox(height: AppSpacing.listItemGap),
              _ActionTile(icon: AppIcons.arrowUp, title: 'Lead Score', subtitle: 'View your engagement score'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title; final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg, boxShadow: AppShadows.card),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.chipBg(AppColors.primary), borderRadius: AppRadius.md), child: Icon(icon, color: AppColors.primary, size: 22)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTypography.headline),
          Text(subtitle, style: AppTypography.footnote),
        ])),
        const Icon(AppIcons.forward, size: 16, color: AppColors.textTertiary),
      ]),
    );
  }
}
