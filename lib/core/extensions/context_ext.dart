import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

extension ContextExt on BuildContext {
  static const int _maxLines = 2;
  static const int _visibleSeconds = 5;

  void showBriefSnack(String message, {SnackBarAction? action}) => _showSnack(message, AppColors.surfaceInverse, action);

  void showSuccessSnack(String message) => _showSnack(message, AppColors.success, null);

  void showErrorSnack(String message) => _showSnack(message, AppColors.danger, null);

  void _showSnack(String message, Color background, SnackBarAction? action) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          action: action,
          backgroundColor: background,
          behavior: SnackBarBehavior.fixed,
          content: Text(message, maxLines: _maxLines, overflow: TextOverflow.ellipsis, style: AppTextStyles.snack),
          duration: const Duration(seconds: _visibleSeconds),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.lg),
        ),
      );
  }
}
