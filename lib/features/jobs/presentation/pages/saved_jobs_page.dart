import 'package:flutter/material.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/empty_state.dart';

class SavedJobsPage extends StatelessWidget {
  const SavedJobsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.savedJobs, style: AppTypography.headline)),
      body: EmptyState(svgPath: AppImages.emptySaved, title: AppStrings.noSavedTitle, subtitle: AppStrings.noSavedSubtitle),
    );
  }
}
