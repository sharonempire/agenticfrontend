import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../blocs/course/course_list_bloc.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(AppStrings.courses, style: AppTypography.largeTitle)),
          BlocBuilder<CourseListBloc, CourseListState>(
            builder: (context, state) {
              if (state.status == CourseListStatus.loading) {
                return const SliverFillRemaining(child: ShimmerList());
              }
              if (state.status == CourseListStatus.error) {
                return SliverFillRemaining(child: ErrorView(message: state.errorMessage, onRetry: () => context.read<CourseListBloc>().add(CourseListRefreshed())));
              }
              if (state.courses.isEmpty && state.status == CourseListStatus.loaded) {
                return SliverFillRemaining(child: EmptyState(svgPath: AppImages.emptyCourses, title: AppStrings.noCoursesTitle, subtitle: AppStrings.noCoursesSubtitle));
              }
              return SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList.separated(
                  itemCount: state.courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listItemGap),
                  itemBuilder: (context, index) {
                    final course = state.courses[index];
                    return GestureDetector(
                      onTap: () => context.push(AppRoutes.courseDetailPath(course.id)),
                      child: Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg, boxShadow: AppShadows.card),
                        child: Row(children: [
                          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: AppRadius.md), child: const Icon(Icons.school, color: AppColors.textTertiary)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(course.title, style: AppTypography.headline, maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (course.provider != null) ...[const SizedBox(height: 4), Text(course.provider!, style: AppTypography.footnote)],
                            const SizedBox(height: 6),
                            Row(children: [
                              if (course.rating != null) ...[const Icon(Icons.star, size: 14, color: AppColors.accent), const SizedBox(width: 4), Text('${course.rating}', style: AppTypography.caption1), const SizedBox(width: 12)],
                              if (course.isFree) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: AppRadius.full), child: Text(AppStrings.free, style: AppTypography.caption2.copyWith(color: AppColors.success, fontWeight: FontWeight.w600))),
                            ]),
                          ])),
                        ]),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
