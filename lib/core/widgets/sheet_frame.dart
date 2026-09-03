import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'dotted_divider.dart';

class SheetFrame extends StatelessWidget {
  const SheetFrame({super.key, required this.title, required this.children});

  final String title;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, maxLines: 1, style: AppTextStyles.sectionHeading),
              const SizedBox(height: AppSpacing.sm),
              const DottedDivider(),
              const SizedBox(height: AppSpacing.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class SheetActions extends StatelessWidget {
  const SheetActions({super.key, required this.primary, required this.secondary});

  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const DottedDivider(),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(child: secondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: primary),
          ],
        ),
      ],
    );
  }
}
