import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';

class AdvanceField extends StatelessWidget {
  const AdvanceField({super.key, required this.advanceCents, required this.onTap});

  final int advanceCents;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (advanceCents == 0) {
      return OutlinedButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Add advance', maxLines: 1), onPressed: onTap);
    }
    return Material(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      color: AppColors.surfaceCard,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          height: AppSpacing.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              const Text('ADVANCE', maxLines: 1, style: AppTextStyles.overline),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Text(advanceCents.asLkr, maxLines: 1, style: AppTextStyles.amount),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
