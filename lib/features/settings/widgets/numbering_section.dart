import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/profile_text_field.dart';

class NumberingSection extends StatelessWidget {
  const NumberingSection({super.key, required this.nextInvoiceNumber, required this.deviceIdFocus, required this.prefixFocus, required this.deviceIdController, required this.prefixController, required this.onChanged, required this.onDone});

  static const int deviceIdLength = 1;
  static const int prefixFlex = 2;
  static const int prefixLength = 6;

  final String nextInvoiceNumber;

  final FocusNode deviceIdFocus;
  final FocusNode prefixFocus;

  final TextEditingController deviceIdController;
  final TextEditingController prefixController;

  final ValueChanged<String> onChanged;

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text('Only future invoices are affected. Give each device its own letter so two tills can never print the same invoice number.', style: AppTextStyles.listSecondary),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: prefixFlex,
              child: ProfileTextField(controller: prefixController, focusNode: prefixFocus, label: 'Prefix', maxLength: prefixLength, nextFocus: deviceIdFocus, onChanged: onChanged),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProfileTextField(controller: deviceIdController, focusNode: deviceIdFocus, label: 'Device', maxLength: deviceIdLength, onChanged: onChanged, onDone: onDone),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Next invoice: $nextInvoiceNumber', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
      ],
    );
  }
}
