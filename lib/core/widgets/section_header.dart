import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'dotted_divider.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(label, maxLines: 1, style: AppTextStyles.overline),
      const SizedBox(height: AppSpacing.sm),
      const DottedDivider(),
      const SizedBox(height: AppSpacing.lg),
    ],
  );
}
