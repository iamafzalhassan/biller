import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

enum SnackTone { error, neutral, success }

extension ContextExt on BuildContext {
  static const int _maxLines = 2;
  static const int _visibleSeconds = 5;

  void showBriefSnack(String message, {SnackBarAction? action}) => _showSnack(message, SnackTone.neutral, action);

  void showSuccessSnack(String message) => _showSnack(message, SnackTone.success, null);

  void showErrorSnack(String message) => _showSnack(message, SnackTone.error, null);

  void _showSnack(String message, SnackTone tone, SnackBarAction? action) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          action: action,
          backgroundColor: switch (tone) {
            SnackTone.error => AppColors.danger,
            SnackTone.neutral => AppColors.surfaceInverse,
            SnackTone.success => AppColors.success,
          },
          behavior: SnackBarBehavior.fixed,
          content: Text(message, maxLines: _maxLines, overflow: TextOverflow.ellipsis, style: AppTextStyles.snack),
          duration: const Duration(seconds: _visibleSeconds),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.lg),
        ),
      );
  }
}
