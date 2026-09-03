import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle heroAmount = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle screenTitle = TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w700, height: 1.2);

  static const TextStyle sectionHeading = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w400, height: 1.3);

  static const TextStyle listPrimary = TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600, height: 1.3);

  static const TextStyle listSecondary = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle totalsValue = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.3,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle totalsValueBold = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle amount = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle overline = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.8,
  );

  static const TextStyle fieldLabel = TextStyle(color: AppColors.textSecondary, fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w500, height: 1.3);

  static const TextStyle fieldValue = TextStyle(color: AppColors.textPrimary, fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600, height: 1.35);

  static const TextStyle hint = TextStyle(
    color: AppColors.textTertiary,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.4,
  );

  static const TextStyle label = TextStyle(color: AppColors.textSecondary, fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.2);

  static const TextStyle recoveryCode = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 3,
  );

  static const TextStyle snack = TextStyle(color: AppColors.primaryOn, fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3);

  static const TextStyle button = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.2);
}
