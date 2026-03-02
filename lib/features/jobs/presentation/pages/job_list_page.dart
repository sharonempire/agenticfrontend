import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../blocs/job/job_list_bloc.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';

class JobListPage extends StatelessWidget {
  const JobListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(AppStrings.jobs, style: AppTypography.largeTitle)),
          BlocBuilder<JobListBloc, JobListState>(
            builder: (context, state) {
              if (state.status == JobListStatus.loading) return const SliverFillRemaining(child: ShimmerList());
              if (state.status == JobListStatus.error) return SliverFillRemaining(child: ErrorView(message: state.errorMessage));
              if (state.jobs.isEmpty && state.status == JobListStatus.loaded) {
                return SliverFillRemaining(child: EmptyState(svgPath: AppImages.emptyJobs, title: AppStrings.noJobsTitle, subtitle: AppStrings.noJobsSubtitle));
              }
              return SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList.separated(
                  itemCount: state.jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listItemGap),
                  itemBuilder: (context, index) {
                    final job = state.jobs[index];
                    return GestureDetector(
                      onTap: () => context.push(AppRoutes.jobDetailPath(job.id)),
                      child: Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg, boxShadow: AppShadows.card),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: AppRadius.md), child: const Icon(AppIcons.briefcase, color: AppColors.textTertiary, size: 24)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(job.title, style: AppTypography.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (job.company != null) Text(job.company!, style: AppTypography.footnote),
                            ])),
                          ]),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(spacing: 12, children: [
                            if (job.location != null) Row(mainAxisSize: MainAxisSize.min, children: [const Icon(AppIcons.locationPin, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text(job.location!, style: AppTypography.caption1)]),
                            if (job.isRemote) Row(mainAxisSize: MainAxisSize.min, children: [const Icon(AppIcons.building, size: 14, color: AppColors.success), const SizedBox(width: 4), Text('Remote', style: AppTypography.caption1.copyWith(color: AppColors.success))]),
                            if (job.type != null) Text(job.type!, style: AppTypography.caption1.copyWith(color: AppColors.textSecondary)),
                          ]),
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
