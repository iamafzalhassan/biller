import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../models/invoice.dart';

final DateFormat _timeFormat = DateFormat('d MMM, h:mm a');

class RecentInvoiceTile extends StatelessWidget {
  const RecentInvoiceTile({super.key, required this.invoice, required this.onTap});

  final Invoice invoice;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        clipBehavior: Clip.antiAlias,
        color: AppColors.surfaceCard,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(invoice.customerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listPrimary),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${invoice.invoiceNumber}  ·  ${_timeFormat.format(invoice.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.listSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(invoice.totalCents.asLkr, maxLines: 1, style: AppTextStyles.totalsValueBold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
