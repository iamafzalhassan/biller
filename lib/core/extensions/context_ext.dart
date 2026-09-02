import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;

  double get keyboardInset => MediaQuery.viewInsetsOf(this).bottom;

  void showBriefSnack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(action: action, content: Text(message)));
  }
}
