import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../models/invoice.dart';

class InvoiceActionsSheet extends StatelessWidget {
  const InvoiceActionsSheet({super.key, required this.invoice, required this.onEditAndReprint, required this.onReprint, required this.onResendEmail});

  final Invoice invoice;

  final VoidCallback onEditAndReprint;
  final VoidCallback onReprint;
  final VoidCallback onResendEmail;

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      minLeadingWidth: AppSpacing.xl,
      onTap: onTap,
      title: Text(label, maxLines: 1, style: AppTextStyles.body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
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
          const Divider(color: AppColors.divider),
          _action(Icons.print_outlined, 'Reprint', onReprint),
          _action(Icons.edit_outlined, 'Edit & Reprint', onEditAndReprint),
          _action(Icons.mail_outline, 'Resend email', onResendEmail),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
