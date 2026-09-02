import 'dart:async';
import 'dart:convert';

import '../../models/invoice.dart';
import '../sources/prefs_source.dart';

class DraftRepository {
  static const int debounceMs = 400;

  final PrefsSource _prefs;

  Timer? _debounce;

  DraftRepository(this._prefs);

  Invoice? get draft {
    final String? raw = _prefs.getString(PrefsSource.keyDraft);
    if (raw == null) return null;
    try {
      final Invoice invoice = Invoice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final bool isEmpty = invoice.customerName.trim().isEmpty && invoice.printableItems.isEmpty;
      return isEmpty ? null : invoice;
    } catch (_) {
      return null;
    }
  }

  void saveDebounced(Invoice invoice) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: debounceMs), () {
      unawaited(_prefs.setString(PrefsSource.keyDraft, jsonEncode(invoice.toJson())));
    });
  }

  Future<void> clear() async {
    _debounce?.cancel();
    await _prefs.remove(PrefsSource.keyDraft);
  }

  void dispose() => _debounce?.cancel();
}
