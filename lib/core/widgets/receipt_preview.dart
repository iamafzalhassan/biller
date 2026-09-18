import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.onLayout, this.loadingWidget});

  final LayoutCallback onLayout;

  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) => PdfPreview(
    allowPrinting: false,
    allowSharing: false,
    build: onLayout,
    canChangeOrientation: false,
    canChangePageFormat: false,
    canDebug: false,
    initialPageFormat: PdfPageFormat.a5,
    loadingWidget: loadingWidget,
    pdfPreviewPageDecoration: const BoxDecoration(color: AppColors.surfaceCard),
    previewPageMargin: const EdgeInsets.all(AppSpacing.md),
    scrollViewDecoration: const BoxDecoration(color: AppColors.surfaceSunken),
    useActions: false,
  );
}
