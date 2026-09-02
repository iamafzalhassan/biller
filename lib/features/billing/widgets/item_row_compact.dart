import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../models/invoice_item.dart';

class ItemRowCompact extends StatelessWidget {
  const ItemRowCompact({super.key, required this.index, required this.item, required this.onTap});

  final int index;

  final InvoiceItem item;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: AppSpacing.itemCardHeight,
            width: AppSpacing.indexColumn,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.cardPadding),
              child: Text('$index.', maxLines: 1, style: AppTextStyles.listSecondary),
            ),
          ),
          Expanded(
            child: Material(
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
                  height: AppSpacing.itemCardHeight,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.listPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${item.qty.asQty} x ${item.unitPriceCents.asAmount}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.listSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: AppSpacing.amountColumnCompact),
                            child: FittedBox(
                              alignment: Alignment.centerRight,
                              fit: BoxFit.scaleDown,
                              child: Text(item.amountCents.asLkr, maxLines: 1, style: AppTextStyles.amount),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
