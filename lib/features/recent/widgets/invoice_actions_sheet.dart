import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../core/widgets/dotted_divider.dart';
import '../../../models/invoice.dart';

class InvoiceActionsSheet extends StatelessWidget {
  const InvoiceActionsSheet({super.key, required this.invoice, required this.onReprint, required this.onSaveCopy});

  final Invoice invoice;

  final VoidCallback onReprint;
  final VoidCallback onSaveCopy;

  Widget _action(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: AppSpacing.iconSheet),
    minLeadingWidth: AppSpacing.xl,
    onTap: onTap,
    title: Text(label, maxLines: 1, style: AppTextStyles.body),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(invoice.invoiceNumber, maxLines: 1, style: AppTextStyles.overline),
              const SizedBox(height: AppSpacing.xs),
              Text(invoice.customerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionHeading),
              const SizedBox(height: AppSpacing.xs),
              Text(invoice.totalCents.asLkr, maxLines: 1, style: AppTextStyles.listSecondary),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: DottedDivider(),
        ),
        _action(Icons.print_outlined, 'Reprint', onReprint),
        _action(Icons.folder_outlined, 'Save a Copy', onSaveCopy),
      ],
    ),
  );
}
