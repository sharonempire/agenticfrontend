import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../blocs/course/course_list_bloc.dart';
import '../../../../blocs/job/job_list_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/course/course.dart';
import '../../../../models/job/job.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppStrings.home, style: AppTypography.largeTitle),
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _CircleAction(
                  icon: AppIcons.notification,
                  onTap: () => context.push(AppRoutes.notifications),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: AppSpacing.pagePadding,
            sliver: SliverList.list(
              children: [
                const _HeroCard(),
                const SizedBox(height: AppSpacing.sectionGap),
                _SectionHeader(
                  title: AppStrings.recommendedCourses,
                  onSeeAll: () => context.go(AppRoutes.courses),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _CoursePreviewStrip(),
                const SizedBox(height: AppSpacing.sectionGap),
                _SectionHeader(
                  title: AppStrings.latestJobs,
                  onSeeAll: () => context.go(AppRoutes.jobs),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _JobPreviewStrip(),
                const SizedBox(height: AppSpacing.sectionGap),
                _SectionHeader(
                  title: AppStrings.aiCopilot,
                  onSeeAll: () => context.go(AppRoutes.aiCopilot),
                ),
                const SizedBox(height: AppSpacing.sm),
                _AiCard(onTap: () => context.go(AppRoutes.aiCopilot)),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Course preview strip (data-driven) ─────────────────────────────

class _CoursePreviewStrip extends StatelessWidget {
  const _CoursePreviewStrip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseListBloc, CourseListState>(
      builder: (context, state) {
        if (state.status == CourseListStatus.loading ||
            state.status == CourseListStatus.initial) {
          return const _ShimmerStrip();
        }
        if (state.status == CourseListStatus.error) {
          return _ErrorStrip(
            message: state.errorMessage ?? 'Failed to load courses',
            onRetry: () => context.read<CourseListBloc>().add(const CourseListFetched(filter: CourseFilter(pageSize: 5))),
          );
        }
        if (state.courses.isEmpty) {
          return const _EmptyStrip(message: 'No courses available');
        }
        return SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: state.courses.length > 5 ? 5 : state.courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final course = state.courses[index];
              return _CourseCard(course: course);
            },
          ),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.courseDetailPath(course.id)),
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.separatorLight, width: 0.6),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.chipBg(AppColors.primary),
                    borderRadius: AppRadius.full,
                  ),
                  child: const Icon(Icons.school, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                if (course.rating != null) ...[
                  const Icon(Icons.star, size: 14, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text('${course.rating}', style: AppTypography.caption1),
                ],
                const Spacer(),
                if (course.isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      AppStrings.free,
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              course.title,
              style: AppTypography.headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.provider != null)
              Text(
                course.provider!,
                style: AppTypography.footnote.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Job preview strip (data-driven) ────────────────────────────────

class _JobPreviewStrip extends StatelessWidget {
  const _JobPreviewStrip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobListBloc, JobListState>(
      builder: (context, state) {
        if (state.status == JobListStatus.loading ||
            state.status == JobListStatus.initial) {
          return const _ShimmerStrip();
        }
        if (state.status == JobListStatus.error) {
          return _ErrorStrip(
            message: state.errorMessage ?? 'Failed to load jobs',
            onRetry: () => context.read<JobListBloc>().add(const JobListFetched(filter: JobFilter(pageSize: 5))),
          );
        }
        if (state.jobs.isEmpty) {
          return const _EmptyStrip(message: 'No jobs available');
        }
        return SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: state.jobs.length > 5 ? 5 : state.jobs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final job = state.jobs[index];
              return _JobCard(job: job);
            },
          ),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.jobDetailPath(job.id)),
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.separatorLight, width: 0.6),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.chipBg(AppColors.secondary),
                    borderRadius: AppRadius.full,
                  ),
                  child: Icon(AppIcons.briefcase, size: 18, color: AppColors.secondary),
                ),
                const SizedBox(width: 8),
                if (job.isRemote)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      'Remote',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.title,
              style: AppTypography.headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                if (job.company != null)
                  Expanded(
                    child: Text(
                      job.company!,
                      style: AppTypography.footnote.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (job.location != null) ...[
                  const SizedBox(width: 8),
                  Icon(AppIcons.locationPin, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 2),
                  Text(
                    job.location!,
                    style: AppTypography.caption2.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ─────────────────────────────────────────────────

class _ShimmerStrip extends StatelessWidget {
  const _ShimmerStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 230,
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: AppRadius.xl,
          ),
        ),
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.separatorLight, width: 0.6),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: AppTypography.footnote.copyWith(color: AppColors.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRetry,
                child: Text('Tap to retry', style: AppTypography.footnote.copyWith(color: AppColors.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  const _EmptyStrip({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.separatorLight, width: 0.6),
      ),
      child: Center(
        child: Text(message, style: AppTypography.footnote.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}

// ─── Reused private widgets ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.title3.copyWith(fontSize: 31 / 1.55)),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              AppStrings.seeAll,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.textLink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.full,
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.full,
            border: Border.all(color: AppColors.separatorLight),
            boxShadow: AppShadows.card,
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xl,
        gradient: LinearGradient(
          colors: [AppColors.surface, const Color(0xFFF7FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.separatorLight, width: 0.6),
        boxShadow: AppShadows.elevated,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.discoverToday, style: AppTypography.title3),
                const SizedBox(height: 6),
                Text(
                  AppStrings.discoverSubtitle,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: AppRadius.full,
              color: AppColors.chipBg(AppColors.primary),
            ),
            child: const Icon(
              AppIcons.sparkle,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          borderRadius: AppRadius.xl,
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF3D7BFF), Color(0xFF5B62E8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: AppShadows.elevated,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: AppRadius.full,
                color: const Color(0x33FFFFFF),
              ),
              child: const Icon(
                AppIcons.sparkle,
                color: AppColors.textInverse,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.smartRecommendations,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.aiSuggestionsSubtitle,
                    style: AppTypography.footnote.copyWith(
                      color: const Color(0xD9FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              AppIcons.forward,
              color: AppColors.textInverse,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
