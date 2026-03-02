import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.go(AppRoutes.onboarding))),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(AppStrings.login, style: AppTypography.largeTitle),
              const SizedBox(height: AppSpacing.sm),
              Text('Welcome back', style: AppTypography.subheadline.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xl),
              TextField(decoration: InputDecoration(hintText: AppStrings.email)),
              const SizedBox(height: AppSpacing.md),
              TextField(decoration: InputDecoration(hintText: AppStrings.password), obscureText: true),
              const SizedBox(height: AppSpacing.sm),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text(AppStrings.forgotPassword, style: AppTypography.footnote.copyWith(color: AppColors.textLink)))),
              const Spacer(),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: () => context.go(AppRoutes.home), child: Text(AppStrings.login, style: AppTypography.buttonLarge.copyWith(color: AppColors.textInverse)))),
              const SizedBox(height: AppSpacing.md),
              SizedBox(width: double.infinity, height: 52, child: OutlinedButton(onPressed: () {}, child: Text(AppStrings.signUp, style: AppTypography.buttonLarge.copyWith(color: AppColors.primary)))),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
