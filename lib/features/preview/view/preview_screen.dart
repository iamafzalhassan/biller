import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_ext.dart';
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
    final String number = ref.read(billingControllerProvider).invoice.invoiceNumber;
    final Uint8List? bytes = await _commit(number);
    if (bytes == null) {
      if (mounted) setState(() => _isPrinting = false);
      return;
    }
    await _sendToPrinter(bytes, number);
  }

  Future<Uint8List?> _commit(String number) async {
    try {
      return await ref.read(billingControllerProvider.notifier).commit();
    } catch (_) {
      if (!mounted) return null;
      context.showErrorSnack('Could not prepare $number. Nothing was printed and the bill is still here, so you can check the details and try again.');
      return null;
    }
  }

  Future<void> _sendToPrinter(Uint8List bytes, String number) async {
    bool hasFailed = false;
    try {
      await PrintService.layout(bytes, name: number);
    } catch (_) {
      hasFailed = true;
    }
    ref.read(billingControllerProvider.notifier).startNewBill();
    if (!mounted) return;
    if (hasFailed) context.showErrorSnack('$number could not be sent to the printer. It is saved, so you can reprint it from Recent invoices.');
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
            child: FilledButton(onPressed: _isPrinting ? null : () => unawaited(_print()), child: const Text('Print', maxLines: 1)),
          ),
        ],
      ),
    );
  }
}
