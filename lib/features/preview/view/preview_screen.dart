import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../billing/controller/billing_controller.dart';
import '../controller/print_service.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bool _isPrinting = false;

  Future<void> _print() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    final BillingController controller = ref.read(billingControllerProvider.notifier);
    final String number = ref.read(billingControllerProvider).invoice.invoiceNumber;
    final Uint8List bytes = await controller.commit();
    await PrintService.layout(bytes, name: number);
    controller.startNewBill();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<Uint8List> _build(PdfPageFormat format) => ref.read(billingControllerProvider.notifier).buildPreviewPdf();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview', maxLines: 1)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PdfPreview(
              allowPrinting: false,
              allowSharing: false,
              build: _build,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              initialPageFormat: PdfPageFormat.a5,
              pdfPreviewPageDecoration: const BoxDecoration(color: AppColors.surfaceCard),
              previewPageMargin: const EdgeInsets.all(AppSpacing.md),
              scrollViewDecoration: const BoxDecoration(color: AppColors.surfaceSunken),
              useActions: false,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
              color: AppColors.surfaceCard,
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done', maxLines: 1)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(onPressed: _isPrinting ? null : () => unawaited(_print()), child: const Text('Print', maxLines: 1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
