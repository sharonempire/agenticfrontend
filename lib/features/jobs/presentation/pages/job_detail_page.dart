import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/job/job_detail_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/error_view.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, required this.jobId});
  final String jobId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobDetailBloc, JobDetailState>(
      builder: (context, state) {
        if (state.status == JobDetailStatus.loading) return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
        if (state.status == JobDetailStatus.error) return Scaffold(appBar: AppBar(), body: ErrorView(message: state.errorMessage));
        final job = state.job;
        if (job == null) return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(job.title),
                actions: [
                  IconButton(
                    icon: Icon(job.isSaved ? AppIcons.bookmarkSystemFilled : AppIcons.bookmarkSystem, color: job.isSaved ? AppColors.primary : null),
                    onPressed: () => context.read<JobDetailBloc>().add(JobSaveToggled(job.id, job.isSaved)),
                  ),
                ],
              ),
              SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList.list(children: [
                  if (job.company != null) Text(job.company!, style: AppTypography.title3.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if (job.location != null) _InfoChip(icon: AppIcons.locationPin, label: job.location!),
                    if (job.isRemote) _InfoChip(icon: AppIcons.building, label: 'Remote', color: AppColors.success),
                    if (job.type != null) _InfoChip(icon: AppIcons.briefcase, label: job.type!),
                  ]),
                  if (job.description != null) ...[const SizedBox(height: AppSpacing.lg), Text('Description', style: AppTypography.title3), const SizedBox(height: AppSpacing.sm), Text(job.description!, style: AppTypography.body.copyWith(color: AppColors.textSecondary))],
                  if (job.skills.isNotEmpty) ...[const SizedBox(height: AppSpacing.lg), Text('Skills', style: AppTypography.title3), const SizedBox(height: AppSpacing.sm), Wrap(spacing: 8, runSpacing: 8, children: job.skills.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.chipBg(AppColors.primary), borderRadius: AppRadius.full), child: Text(s, style: AppTypography.caption1.copyWith(color: AppColors.primary)))).toList())],
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(child: Padding(padding: AppSpacing.pagePadding.copyWith(top: 12, bottom: 12), child: SizedBox(height: 52, child: FilledButton(onPressed: () {}, child: Text(job.isApplied ? AppStrings.applied : AppStrings.applyNow, style: AppTypography.buttonLarge.copyWith(color: AppColors.textInverse)))))),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});
  final IconData icon; final String label; final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.chipBg(c), borderRadius: AppRadius.full),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: c), const SizedBox(width: 4), Text(label, style: AppTypography.caption1.copyWith(color: c))]),
    );
  }
}
