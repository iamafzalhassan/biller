import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../models/invoice_item.dart';

class ItemRowWide extends StatelessWidget {
  const ItemRowWide({super.key, required this.index, required this.item, required this.onTap});

  final int index;

  final InvoiceItem item;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceBase,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          height: AppSpacing.rowHeight,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: AppSpacing.indexColumn,
                child: Text('$index.', maxLines: 1, style: AppTextStyles.listSecondary),
              ),
              Expanded(
                child: Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: AppSpacing.qtyColumn,
                child: Text(item.qty.asQty, maxLines: 1, style: AppTextStyles.amount, textAlign: TextAlign.right),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: AppSpacing.priceColumn,
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Text(item.unitPriceCents.asAmount, maxLines: 1, style: AppTextStyles.amount),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: AppSpacing.amountColumn,
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Text(item.amountCents.asLkr, maxLines: 1, style: AppTextStyles.amount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
