import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class BillingPhoneLayout extends StatelessWidget {
  const BillingPhoneLayout({
    super.key,
    required this.itemRows,
    required this.scrollController,
    required this.addItemButton,
    required this.advanceField,
    required this.customerField,
    required this.draftBanner,
    required this.emptyState,
    required this.totalsPanel,
  });

  final List<Widget> itemRows;

  final ScrollController scrollController;

  final Widget addItemButton;
  final Widget advanceField;
  final Widget customerField;
  final Widget? draftBanner;
  final Widget? emptyState;
  final Widget totalsPanel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
            ),
            children: <Widget>[
              if (draftBanner != null) draftBanner!,
              customerField,
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.divider),
              const SizedBox(height: AppSpacing.lg),
              const Text('ITEMS', maxLines: 1, style: AppTextStyles.overline),
              const SizedBox(height: AppSpacing.md),
              if (emptyState != null) emptyState!,
              ...itemRows,
              const SizedBox(height: AppSpacing.sm),
              addItemButton,
              const SizedBox(height: AppSpacing.md),
              advanceField,
            ],
          ),
        ),
        totalsPanel,
      ],
    );
  }
}
