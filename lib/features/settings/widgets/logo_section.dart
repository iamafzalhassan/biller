import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key, required this.logoPath, required this.onPick, required this.onRemove});

  final String logoPath;

  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _hasLogo => logoPath.isNotEmpty;

  Widget _preview() => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusCard), color: AppColors.surfaceField),
    height: AppSpacing.logoPreview,
    width: AppSpacing.logoPreview,
    child: _hasLogo
        ? ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: Image.file(File(logoPath), key: ValueKey<String>(logoPath), fit: BoxFit.cover),
          )
        : const Icon(Icons.image_outlined, color: AppColors.textTertiary, size: AppSpacing.iconPlaceholder),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        children: <Widget>[
          _preview(),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(_hasLogo ? 'Prints above the business name on every receipt.' : 'No logo. It prints above the business name.', style: AppTextStyles.listSecondary)),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.upload_outlined, size: AppSpacing.iconButton),
              label: Text(_hasLogo ? 'Replace Logo' : 'Upload Logo', maxLines: 1),
              onPressed: onPick,
            ),
          ),
          if (_hasLogo) const SizedBox(width: AppSpacing.md),
          if (_hasLogo)
            Expanded(
              child: OutlinedButton(onPressed: onRemove, style: AppTheme.dangerButton, child: const Text('Remove', maxLines: 1)),
            ),
        ],
      ),
    ],
  );
}
