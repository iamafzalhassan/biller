import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../models/invoice_item.dart';

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item, required this.onTap});

  final InvoiceItem item;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceBase,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.listPrimary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppSpacing.amountColumn),
                    child: FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(item.amountCents.asLkr, maxLines: 1, style: AppTextStyles.listPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('QTY ${item.qty.asQty} X ${item.unitPriceCents.asAmount}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
