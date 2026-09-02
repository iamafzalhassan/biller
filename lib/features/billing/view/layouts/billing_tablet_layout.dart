import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class BillingTabletLayout extends StatelessWidget {
  const BillingTabletLayout({
    super.key,
    required this.itemRows,
    required this.scrollController,
    required this.addItemButton,
    required this.advanceField,
    required this.customerField,
    required this.draftBanner,
    required this.emptyState,
    required this.itemsHeader,
    required this.previewPane,
    required this.totalsPanel,
  });

  final List<Widget> itemRows;

  final ScrollController scrollController;

  final Widget addItemButton;
  final Widget advanceField;
  final Widget customerField;
  final Widget? draftBanner;
  final Widget? emptyState;
  final Widget? itemsHeader;
  final Widget previewPane;
  final Widget totalsPanel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 6,
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
              if (itemsHeader != null) itemsHeader!,
              if (emptyState != null) emptyState!,
              ...itemRows,
              const SizedBox(height: AppSpacing.md),
              addItemButton,
              const SizedBox(height: AppSpacing.md),
              advanceField,
            ],
          ),
        ),
        const VerticalDivider(color: AppColors.divider, thickness: AppSpacing.hairline, width: AppSpacing.hairline),
        Expanded(
          flex: 4,
          child: Column(
            children: <Widget>[
              Expanded(child: previewPane),
              totalsPanel,
            ],
          ),
        ),
      ],
    );
  }
}
