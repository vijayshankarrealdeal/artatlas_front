import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double blurSigma;
  final double borderRadius;

  GradientBorderPainter({
    required this.gradient,
    this.strokeWidth = 48,
    this.blurSigma = 45,
    this.borderRadius = 38,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = blurSigma > 0
          ? MaskFilter.blur(BlurStyle.normal, blurSigma)
          : null;

    if (borderRadius <= 0) {
      canvas.drawRect(rect, paint);
    } else {
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.blurSigma != blurSigma ||
      oldDelegate.borderRadius != borderRadius;
}
