import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key, this.color = AppColors.dividerStrong});

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DottedPainter(color), size: const Size(double.infinity, 1));
}

class _DottedPainter extends CustomPainter {
  static const double dashGap = 4;
  static const double dashWidth = 3;

  final Color color;

  const _DottedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += dashWidth + dashGap) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DottedPainter oldDelegate) => oldDelegate.color != color;
}
