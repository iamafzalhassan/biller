import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';

class BillingTabletLayout extends StatelessWidget {
  const BillingTabletLayout({
    super.key,
    required this.itemRows,
    required this.scrollController,
    required this.addItemButton,
    required this.customerField,
    required this.draftBanner,
    required this.previewPane,
    required this.printButton,
    required this.totalsSection,
  });

  final List<Widget> itemRows;

  final ScrollController scrollController;

  final Widget addItemButton;
  final Widget customerField;
  final Widget? draftBanner;
  final Widget previewPane;
  final Widget printButton;
  final Widget totalsSection;

  Widget _inset(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom),
            children: <Widget>[
              if (draftBanner != null) _inset(draftBanner!),
              _inset(const SectionHeader(label: 'CUSTOMER')),
              _inset(customerField),
              const SizedBox(height: AppSpacing.xl),
              _inset(const SectionHeader(label: 'DETAIL ITEMS')),
              ...itemRows,
              if (itemRows.isNotEmpty) const SizedBox(height: AppSpacing.sm),
              _inset(addItemButton),
              const SizedBox(height: AppSpacing.xl),
              _inset(totalsSection),
              const SizedBox(height: AppSpacing.lg),
              _inset(printButton),
            ],
          ),
        ),
        const VerticalDivider(color: AppColors.divider, thickness: AppSpacing.hairline, width: AppSpacing.hairline),
        Expanded(flex: 4, child: previewPane),
      ],
    );
  }
}
