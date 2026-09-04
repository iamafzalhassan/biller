import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract final class SoftKeyboard {
  static const int startupAttempts = 10;
  static const int startupIntervalMs = 250;

  static bool get isOpen {
    final FlutterView? view = WidgetsBinding.instance.platformDispatcher.implicitView;
    return view != null && view.viewInsets.bottom > 0;
  }

  static Future<void> openOnStartup(FocusNode node, bool Function() isMounted) async {
    for (int attempt = 0; attempt < startupAttempts; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: startupIntervalMs));
      if (!isMounted() || isOpen) return;
      if (!node.hasFocus) node.requestFocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }
  }
}
