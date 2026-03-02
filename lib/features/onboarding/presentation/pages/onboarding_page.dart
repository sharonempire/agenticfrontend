import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(AppStrings.appName, style: AppTypography.largeTitle),
              const SizedBox(height: AppSpacing.sm),
              Text('Find courses and jobs tailored for you', style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const Spacer(),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: () => context.go(AppRoutes.login), child: Text(AppStrings.getStarted, style: AppTypography.buttonLarge.copyWith(color: AppColors.textInverse)))),
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: () => context.go(AppRoutes.home), child: Text(AppStrings.guestMode, style: AppTypography.subheadline.copyWith(color: AppColors.textLink))),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
