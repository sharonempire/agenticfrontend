import 'package:flutter/material.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_strings.dart';
import 'empty_state.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      svgPath: AppImages.errorState,
      title: AppStrings.errorTitle,
      subtitle: message ?? AppStrings.errorSubtitle,
      actionLabel: AppStrings.retry,
      onAction: onRetry,
    );
  }
}
