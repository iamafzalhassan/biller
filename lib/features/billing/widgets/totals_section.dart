import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/widgets/dotted_divider.dart';

class TotalsSection extends StatelessWidget {
  const TotalsSection({
    super.key,
    required this.advanceCents,
    required this.balanceCents,
    required this.showsAdvance,
    required this.totalCents,
    required this.onAdvanceTap,
  });

  final bool showsAdvance;

  final int advanceCents;
  final int balanceCents;
  final int totalCents;

  final VoidCallback onAdvanceTap;

  Widget _line(String label, int cents, {required bool isBold, bool isEditable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Text(label, maxLines: 1, style: AppTextStyles.overline),
          if (isEditable)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.xs),
              child: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: AppSpacing.iconInline),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(cents.asLkr, maxLines: 1, style: isBold ? AppTextStyles.totalsValueBold : AppTextStyles.totalsValue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusCard), color: AppColors.surfaceField),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: totalCents.asAmount));
              HapticFeedback.mediumImpact();
              context.showBriefSnack('Total copied to the clipboard, ready to paste into a message.');
            },
            child: _line('TOTAL', totalCents, isBold: true),
          ),
          if (showsAdvance) const DottedDivider(),
          if (showsAdvance) InkWell(onTap: onAdvanceTap, child: _line('ADVANCE', advanceCents, isBold: false, isEditable: true)),
          if (showsAdvance) const DottedDivider(),
          if (showsAdvance) _line('BALANCE', balanceCents, isBold: false),
          if (!showsAdvance) const SizedBox(height: AppSpacing.sm),
          if (!showsAdvance)
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: AppSpacing.iconButton),
              label: const Text('Add Advance', maxLines: 1),
              onPressed: onAdvanceTap,
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
