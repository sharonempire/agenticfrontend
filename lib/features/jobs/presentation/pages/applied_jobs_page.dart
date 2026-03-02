import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';

class AppliedJobsPage extends StatelessWidget {
  const AppliedJobsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appliedJobs, style: AppTypography.headline)),
      body: const Center(child: Text('Applied jobs appear here')),
    );
  }
}
