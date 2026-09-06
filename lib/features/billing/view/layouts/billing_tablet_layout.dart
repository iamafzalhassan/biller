import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class BillingTabletLayout extends StatelessWidget {
  const BillingTabletLayout({super.key, required this.form, required this.previewPane});

  static const int formFlex = 6;
  static const int previewFlex = 4;

  final Widget form;
  final Widget previewPane;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(flex: formFlex, child: form),
        const VerticalDivider(color: AppColors.divider, thickness: AppSpacing.hairline, width: AppSpacing.hairline),
        Expanded(flex: previewFlex, child: previewPane),
      ],
    );
  }
}
