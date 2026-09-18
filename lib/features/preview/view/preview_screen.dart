import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/widgets/receipt_preview.dart';

import '../../../printing/print_outcome.dart';

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
    final PrintOutcome outcome = await ref.read(billingControllerProvider.notifier).printBill();
    if (!mounted) return;
    if (!outcome.isSilent) context.showErrorSnack(outcome.message(number));
    if (outcome == PrintOutcome.commitFailed) {
      setState(() => _isPrinting = false);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<Uint8List> _build(PdfPageFormat format) => ref.read(billingControllerProvider.notifier).buildPreviewPdf();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Preview', maxLines: 1)),
    body: Column(
      children: <Widget>[
        Expanded(child: ReceiptPreview(onLayout: _build)),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
            color: AppColors.surfaceCard,
          ),
          padding: EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.lg + MediaQuery.paddingOf(context).bottom),
          child: FilledButton(onPressed: _isPrinting ? null : () => unawaited(_print()), child: const Text('Print', maxLines: 1)),
        ),
      ],
    ),
  );
}
