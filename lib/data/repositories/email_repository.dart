import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice.dart';
import '../sources/email_api_client.dart';
import '../sources/prefs_source.dart';

class EmailRepository {
  static const int maxQueued = 50;

  final EmailApiClient _client;

  final PrefsSource _prefs;

  EmailRepository(this._client, this._prefs);

  int get queuedCount => _prefs.getStringList(PrefsSource.keyOutbox).length;

  Future<void> enqueue({required Invoice invoice, required String ownerEmail, required Uint8List pdfBytes}) async {
    final Map<String, dynamic> payload = _buildPayload(invoice: invoice, ownerEmail: ownerEmail, pdfBytes: pdfBytes);
    await _append(payload);
    await flush();
  }

  Future<void> flush() async {
    final List<String> queue = _prefs.getStringList(PrefsSource.keyOutbox);
    if (queue.isEmpty) return;
    final List<String> remaining = <String>[];
    for (final String raw in queue) {
      final bool sent = await _client.send(jsonDecode(raw) as Map<String, dynamic>);
      if (!sent) remaining.add(raw);
    }
    await _prefs.setStringList(PrefsSource.keyOutbox, remaining);
  }

  Map<String, dynamic> _buildPayload({required Invoice invoice, required String ownerEmail, required Uint8List pdfBytes}) {
    return <String, dynamic>{
      'isRevised': invoice.isRevised,
      'previousTotalCents': invoice.previousTotalCents,
      'totalCents': invoice.totalCents,
      'customerName': invoice.customerName,
      'invoiceNumber': invoice.invoiceNumber,
      'ownerEmail': ownerEmail,
      'pdfBase64': base64Encode(pdfBytes),
      'subject': '${invoice.invoiceNumber} · ${invoice.customerName} · ${invoice.totalCents.asLkr}',
      'createdAt': invoice.createdAt.toIso8601String(),
    };
  }

  Future<void> _append(Map<String, dynamic> payload) async {
    final List<String> queue = _prefs.getStringList(PrefsSource.keyOutbox)..add(jsonEncode(payload));
    if (queue.length > maxQueued) queue.removeRange(0, queue.length - maxQueued);
    await _prefs.setStringList(PrefsSource.keyOutbox, queue);
  }
}
