import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../models/invoice.dart';
import '../../../pdf/receipt_builder.dart';

class LivePreviewPane extends ConsumerStatefulWidget {
  const LivePreviewPane({super.key});

  @override
  ConsumerState<LivePreviewPane> createState() => _LivePreviewPaneState();
}

class _LivePreviewPaneState extends ConsumerState<LivePreviewPane> {
  static const int debounceMs = 500;

  int _previewSeed = 0;

  Invoice? _snapshot;

  Timer? _debounce;

  void _scheduleRebuild(Invoice invoice) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: debounceMs), () {
      if (!mounted) return;
      setState(() {
        _previewSeed++;
        _snapshot = invoice;
      });
    });
  }

  Future<Uint8List> _build(PdfPageFormat format) async {
    final Invoice? invoice = _snapshot;
    if (invoice == null) return Uint8List(0);
    return ReceiptBuilder.build(profile: ref.read(settingsRepositoryProvider).profile, invoice: invoice);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Invoice invoice = ref.watch(billingControllerProvider).invoice;
    if (invoice != _snapshot) _scheduleRebuild(invoice);
    if (_snapshot == null) {
      return const ColoredBox(
        color: AppColors.surfaceSunken,
        child: Center(child: Text('The receipt appears here as you type')),
      );
    }
    return PdfPreview(
      key: ValueKey<int>(_previewSeed),
      allowPrinting: false,
      allowSharing: false,
      build: _build,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      initialPageFormat: PdfPageFormat.a5,
      loadingWidget: const SizedBox.shrink(),
      pdfPreviewPageDecoration: const BoxDecoration(color: AppColors.surfaceCard),
      previewPageMargin: const EdgeInsets.all(AppSpacing.md),
      scrollViewDecoration: const BoxDecoration(color: AppColors.surfaceSunken),
      useActions: false,
    );
  }
}
