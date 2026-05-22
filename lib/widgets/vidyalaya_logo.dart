import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The Vidyalaya logo mark: two stylized overlapping "V" shapes —
/// a dark navy V on the left and a teal hooked V on the right.
class VidyalayaLogo extends StatelessWidget {
  final double size;
  const VidyalayaLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  static const _navy = Color(0xFF1E2A3A);
  static const _teal = AppColors.teal;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Left dark navy "V" — solid angular blade pointing down-right.
    final navyPaint = Paint()
      ..color = _navy
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final navyV = Path()
      ..moveTo(w * 0.08, h * 0.12)
      ..lineTo(w * 0.30, h * 0.12)
      ..lineTo(w * 0.55, h * 0.80)
      ..lineTo(w * 0.46, h * 0.96)
      ..lineTo(w * 0.34, h * 0.96)
      ..close();
    canvas.drawPath(navyV, navyPaint);

    // Right teal "V" — swooping blade with a curled flag at the top-right.
    final tealPaint = Paint()
      ..color = _teal
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final tealV = Path()
      // Top-right curl/flag
      ..moveTo(w * 0.60, h * 0.08)
      ..quadraticBezierTo(w * 0.95, h * -0.02, w * 0.96, h * 0.20)
      ..quadraticBezierTo(w * 0.86, h * 0.22, w * 0.78, h * 0.24)
      // Down the right blade to the point
      ..lineTo(w * 0.52, h * 0.96)
      ..lineTo(w * 0.44, h * 0.96)
      ..lineTo(w * 0.42, h * 0.84)
      ..lineTo(w * 0.56, h * 0.24)
      ..close();
    canvas.drawPath(tealV, tealPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
