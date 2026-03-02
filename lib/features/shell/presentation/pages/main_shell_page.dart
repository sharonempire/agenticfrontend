import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: AppRadius.xl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.88),
                borderRadius: AppRadius.xl,
                border: Border.all(color: AppColors.separatorLight, width: 0.6),
                boxShadow: AppShadows.bottomBar,
              ),
              child: Row(
                children: [
                  _NavItem(
                    svg: AppIcons.navHome,
                    label: AppStrings.home,
                    selected: navigationShell.currentIndex == 0,
                    onTap: () => navigationShell.goBranch(0),
                  ),
                  _NavItem(
                    svg: AppIcons.navCourses,
                    label: AppStrings.courses,
                    selected: navigationShell.currentIndex == 1,
                    onTap: () => navigationShell.goBranch(1),
                  ),
                  _NavItem(
                    svg: AppIcons.navJobs,
                    label: AppStrings.jobs,
                    selected: navigationShell.currentIndex == 2,
                    onTap: () => navigationShell.goBranch(2),
                  ),
                  _NavItem(
                    svg: AppIcons.navAi,
                    label: AppStrings.aiCopilot,
                    selected: navigationShell.currentIndex == 3,
                    onTap: () => navigationShell.goBranch(3),
                  ),
                  _NavItem(
                    svg: AppIcons.navProfile,
                    label: AppStrings.profile,
                    selected: navigationShell.currentIndex == 4,
                    onTap: () => navigationShell.goBranch(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.svg,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String svg;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.chipBg(AppColors.primary)
                    : Colors.transparent,
                borderRadius: AppRadius.full,
              ),
              child: SvgPicture.asset(
                svg,
                width: 21,
                height: 21,
                colorFilter: ColorFilter.mode(
                  selected ? AppColors.primary : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption2.copyWith(
                color: selected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: selected ? AppFonts.semibold : AppFonts.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
