import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_spacing.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppShadows.bottomBar, border: const Border(top: BorderSide(color: AppColors.separatorLight, width: 0.5))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(svg: AppIcons.navHome, label: AppStrings.home, selected: navigationShell.currentIndex == 0, onTap: () => navigationShell.goBranch(0)),
                _NavItem(svg: AppIcons.navCourses, label: AppStrings.courses, selected: navigationShell.currentIndex == 1, onTap: () => navigationShell.goBranch(1)),
                _NavItem(svg: AppIcons.navJobs, label: AppStrings.jobs, selected: navigationShell.currentIndex == 2, onTap: () => navigationShell.goBranch(2)),
                _NavItem(svg: AppIcons.navAi, label: AppStrings.aiCopilot, selected: navigationShell.currentIndex == 3, onTap: () => navigationShell.goBranch(3)),
                _NavItem(svg: AppIcons.navProfile, label: AppStrings.profile, selected: navigationShell.currentIndex == 4, onTap: () => navigationShell.goBranch(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.svg, required this.label, required this.selected, required this.onTap});
  final String svg; final String label; final bool selected; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: selected ? AppColors.chipBg(AppColors.primary) : Colors.transparent, borderRadius: AppRadius.full),
              child: SvgPicture.asset(svg, width: 24, height: 24, colorFilter: ColorFilter.mode(selected ? AppColors.primary : AppColors.textTertiary, BlendMode.srcIn)),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption2.copyWith(color: selected ? AppColors.primary : AppColors.textTertiary, fontWeight: selected ? AppFonts.semibold : AppFonts.regular)),
          ],
        ),
      ),
    );
  }
}
