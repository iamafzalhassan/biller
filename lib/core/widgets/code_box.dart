import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_ext.dart';

class CodeBox extends StatelessWidget {
  const CodeBox({super.key, required this.code, required this.copiedMessage, required this.label});

  final String code;
  final String copiedMessage;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusCard), color: AppColors.surfaceField),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          children: <Widget>[
            Text(label, maxLines: 1, style: AppTextStyles.overline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(code, maxLines: 1, style: AppTextStyles.recoveryCode, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      OutlinedButton.icon(
        icon: const Icon(Icons.copy_outlined, size: AppSpacing.iconButton),
        label: const Text('Copy Code', maxLines: 1),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: code));
          HapticFeedback.mediumImpact();
          context.showSuccessSnack(copiedMessage);
        },
      ),
    ],
  );
}
