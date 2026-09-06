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

  static void release() => FocusManager.instance.primaryFocus?.unfocus();

  static void dismiss() {
    _hide();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _hide());
  }

  static Future<void> openFor(FocusNode node, bool Function() isActive) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!isActive()) return;
    node.requestFocus();
    for (int attempt = 0; attempt < openAttempts; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: openIntervalMs));
      if (!isActive() || !node.hasFocus || isOpen) return;
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }
  }

  static void _hide() {
    release();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide').ignore();
  }
}
