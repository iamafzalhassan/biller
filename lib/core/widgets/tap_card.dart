import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class TapCard extends StatelessWidget {
  const TapCard({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
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
        child: child,
      ),
    ),
  );
}
