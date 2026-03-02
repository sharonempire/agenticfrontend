import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/course/course_detail_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/error_view.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        if (state.status == CourseDetailStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (state.status == CourseDetailStatus.error) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(message: state.errorMessage),
          );
        }
        final course = state.course;
        if (course == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(title: Text(course.title)),
              SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList.list(
                  children: [
                    if (course.provider != null)
                      Text(
                        course.provider!,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (course.level != null)
                          _Chip(label: course.level!, color: AppColors.primary),
                        if (course.duration != null)
                          _Chip(
                            label: course.duration!,
                            color: AppColors.secondary,
                          ),
                        if (course.isFree)
                          _Chip(
                            label: AppStrings.free,
                            color: AppColors.success,
                          ),
                        if (course.isEligible == true)
                          _Chip(
                            label: AppStrings.eligibleLabel,
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                    if (course.description != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text('About', style: AppTypography.title3),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        course.description!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: AppSpacing.pagePadding.copyWith(top: 12, bottom: 12),
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () {},
                  child: Text(
                    AppStrings.enrollNow,
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBg(color),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: AppTypography.caption1.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
