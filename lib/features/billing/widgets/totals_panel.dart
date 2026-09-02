import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/widgets/dotted_divider.dart';

class TotalsPanel extends StatelessWidget {
  const TotalsPanel({
    super.key,
    required this.advanceCents,
    required this.balanceCents,
    required this.buttonLabel,
    required this.canPrint,
    required this.isPrinting,
    required this.showsAdvance,
    required this.totalCents,
    required this.onBlockedTap,
    required this.onPrint,
  });

  final bool canPrint;
  final bool isPrinting;
  final bool showsAdvance;

  final int advanceCents;
  final int balanceCents;
  final int totalCents;

  final String buttonLabel;

  final VoidCallback onBlockedTap;
  final VoidCallback onPrint;

  Widget _totalLine(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: totalCents.asAmount));
        HapticFeedback.mediumImpact();
        context.showBriefSnack('Total copied');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text('TOTAL', maxLines: 1, style: AppTextStyles.overline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(totalCents.asLkr, maxLines: 1, style: AppTextStyles.heroAmount),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondaryLine(String label, int cents, {required bool isStrong}) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Text(label, maxLines: 1, style: AppTextStyles.overline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(cents.asLkr, maxLines: 1, style: isStrong ? AppTextStyles.amount : AppTextStyles.listSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
        color: AppColors.surfaceCard,
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.lg + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _totalLine(context),
          if (showsAdvance)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: DottedDivider(),
            ),
          if (showsAdvance) _secondaryLine('ADVANCE', advanceCents, isStrong: false),
          if (showsAdvance) _secondaryLine('BALANCE', balanceCents, isStrong: true),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: canPrint ? null : onBlockedTap,
            child: FilledButton(
              onPressed: canPrint ? onPrint : null,
              child: isPrinting
                  ? const SizedBox(
                      height: AppSpacing.progressIndicator,
                      width: AppSpacing.progressIndicator,
                      child: CircularProgressIndicator(color: AppColors.primaryOn, strokeWidth: 2),
                    )
                  : Text(buttonLabel, maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}
