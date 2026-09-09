import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_channels.dart';

class ReceiptFileSource {
  static const String folderLabel = 'Download/Biller/Invoices';

  Future<String> write(String fileName, Uint8List bytes) async {
    if (Platform.isAndroid) {
      final String? savedPath = await AppChannels.receipts.invokeMethod<String>('saveReceipt', <String, Object>{'fileName': fileName, 'bytes': bytes});
      if (savedPath != null) return savedPath;
    }
    return _writeToAppDirectory(fileName, bytes);
  }

  Future<String> _writeToAppDirectory(String fileName, Uint8List bytes) async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory folder = Directory('${base.path}${Platform.pathSeparator}Invoices');
    if (!folder.existsSync()) await folder.create(recursive: true);
    final File file = File('${folder.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
