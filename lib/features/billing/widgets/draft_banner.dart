import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final DateFormat _timeFormat = DateFormat('h:mm a');

class DraftBanner extends StatelessWidget {
  const DraftBanner({super.key, required this.savedAt, required this.onDiscard, required this.onRestore});

  final DateTime savedAt;

  final VoidCallback onDiscard;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        color: AppColors.warning.withValues(alpha: 0.08),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text('Unsaved bill from ${_timeFormat.format(savedAt)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: AppSpacing.touchTarget,
            child: TextButton(onPressed: onDiscard, child: const Text('Discard', maxLines: 1)),
          ),
          SizedBox(
            height: AppSpacing.touchTarget,
            child: TextButton(onPressed: onRestore, child: const Text('Restore', maxLines: 1)),
          ),
        ],
      ),
    );
  }
}
