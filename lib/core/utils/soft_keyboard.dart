import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract final class SoftKeyboard {
  static const int openAttempts = 8;
  static const int openIntervalMs = 150;

  static bool get isOpen {
    final FlutterView? view = WidgetsBinding.instance.platformDispatcher.implicitView;
    return view != null && view.viewInsets.bottom > 0;
  }

  static void dismiss() {
    _release();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _release());
  }

  static Future<void> openFor(FocusNode node, bool Function() isActive) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!isActive()) return;
    node.requestFocus();
    for (int attempt = 0; attempt < openAttempts; attempt++) {
      if (!isActive() || !node.hasFocus) return;
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      if (isOpen) return;
      await Future<void>.delayed(const Duration(milliseconds: openIntervalMs));
    }
  }

  static void _release() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide').ignore();
  }
}
