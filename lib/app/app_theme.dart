import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(error: AppColors.danger, primary: AppColors.primary, onPrimary: AppColors.primaryOn, seedColor: AppColors.primary, surface: AppColors.surfaceBase);
    return ThemeData(
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.surfaceBase,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceBase,
        centerTitle: false,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSpacing.screenPadding,
        titleTextStyle: AppTextStyles.screenTitle,
        toolbarHeight: AppSpacing.appBarHeight,
      ),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppColors.surfaceCard, elevation: 0, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
        surfaceTintColor: Colors.transparent,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: AppColors.surfaceCard,
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        collapsedBackgroundColor: AppColors.surfaceCard,
        collapsedIconColor: AppColors.textSecondary,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: const BorderSide(color: AppColors.divider),
        ),
        collapsedTextColor: AppColors.textPrimary,
        iconColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: const BorderSide(color: AppColors.divider),
        ),
        textColor: AppColors.textPrimary,
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, space: AppSpacing.hairline, thickness: AppSpacing.hairline),
      filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary, minimumSize: const Size.square(AppSpacing.iconButtonSize), shape: const CircleBorder()),
      ),
      inputDecorationTheme: _inputDecorationTheme,
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minVerticalPadding: AppSpacing.md,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedButtonStyle),
      snackBarTheme: const SnackBarThemeData(actionTextColor: AppColors.primaryOn, backgroundColor: AppColors.surfaceInverse, behavior: SnackBarBehavior.fixed, contentTextStyle: AppTextStyles.snack, shape: RoundedRectangleBorder()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, minimumSize: const Size(0, AppSpacing.touchTarget), textStyle: AppTextStyles.listPrimary),
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary),
    );
  }

  static ButtonStyle get _filledButtonStyle => FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    disabledBackgroundColor: AppColors.surfaceSunken,
    disabledForegroundColor: AppColors.textDisabled,
    elevation: 0,
    foregroundColor: AppColors.primaryOn,
    maximumSize: const Size.fromHeight(AppSpacing.buttonHeight),
    minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: AppTextStyles.button,
  );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    border: _border(AppColors.divider),
    constraints: const BoxConstraints(minHeight: AppSpacing.controlHeight),
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
    disabledBorder: _border(AppColors.divider),
    enabledBorder: _border(AppColors.divider),
    errorBorder: _border(AppColors.danger),
    errorStyle: const TextStyle(color: AppColors.danger, fontFamily: AppTextStyles.fontFamily, fontSize: 12, height: 1.2),
    fillColor: AppColors.surfaceCard,
    filled: true,
    floatingLabelStyle: const TextStyle(color: AppColors.primary, fontFamily: AppTextStyles.fontFamily, fontSize: 13, height: 1.2),
    focusedBorder: _border(AppColors.primary, width: AppSpacing.borderFocus),
    focusedErrorBorder: _border(AppColors.danger, width: AppSpacing.borderFocus),
    hintStyle: AppTextStyles.hint,
    isDense: true,
    labelStyle: AppTextStyles.label,
    prefixStyle: AppTextStyles.amount,
  );

  static ButtonStyle get _outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    maximumSize: const Size.fromHeight(AppSpacing.buttonHeight),
    minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
    side: const BorderSide(color: AppColors.primary),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: AppTextStyles.button,
  );

  static OutlineInputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusField),
    borderSide: BorderSide(color: color, width: width),
  );
}
