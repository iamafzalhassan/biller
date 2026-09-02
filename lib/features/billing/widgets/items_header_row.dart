import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ItemsHeaderRow extends StatelessWidget {
  const ItemsHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.dividerStrong)),
      ),
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: AppSpacing.indexColumn,
            child: Text('NO', maxLines: 1, style: AppTextStyles.overline),
          ),
          const Expanded(
            child: Text('DESCRIPTION', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.overline),
          ),
          const SizedBox(width: AppSpacing.md),
          const SizedBox(
            width: AppSpacing.qtyColumn,
            child: Text('QTY', maxLines: 1, style: AppTextStyles.overline, textAlign: TextAlign.right),
          ),
          const SizedBox(width: AppSpacing.md),
          const SizedBox(
            width: AppSpacing.priceColumn,
            child: Text('PRICE', maxLines: 1, style: AppTextStyles.overline, textAlign: TextAlign.right),
          ),
          const SizedBox(width: AppSpacing.md),
          const SizedBox(
            width: AppSpacing.amountColumn,
            child: Text('AMOUNT', maxLines: 1, style: AppTextStyles.overline, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
