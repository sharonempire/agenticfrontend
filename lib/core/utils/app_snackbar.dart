import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._();

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
