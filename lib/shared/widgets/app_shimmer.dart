import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, this.height = 120, this.width, this.borderRadius});
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.separatorLight,
      highlightColor: AppColors.surface,
      child: Container(
        height: height, width: width,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: borderRadius ?? AppRadius.md),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listItemGap),
      itemBuilder: (_, __) => const AppShimmer(height: 100),
    );
  }
}
