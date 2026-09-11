import 'package:flutter/material.dart';
import 'package:udghosh/theme/arena_theme.dart';

/// Clips a single hard chamfer out of the top-right corner — the
/// "physical player credential" cut used across the arena-pass system.
class ChamferClipper extends CustomClipper<Path> {
  final double chamfer;
  const ChamferClipper({this.chamfer = 8});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w - chamfer, 0)
      ..lineTo(w, chamfer)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant ChamferClipper oldClipper) =>
      oldClipper.chamfer != chamfer;
}

/// A flat, hard-edged container with a single chamfered top-right corner,
/// a matte fill and a 1.5px technical border. Used for the match card
/// shell and any tile that should read as a cut credential rather than
/// a floating rounded card.
class ChamferedBox extends StatelessWidget {
  final Widget child;
  final double chamfer;
  final Color fill;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  const ChamferedBox({
    super.key,
    required this.child,
    this.chamfer = 8,
    this.fill = ArenaColors.surface,
    this.borderColor = ArenaColors.border,
    this.borderWidth = 1.5,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ChamferClipper(chamfer: chamfer),
      child: CustomPaint(
        painter: _ChamferBorderPainter(
          chamfer: chamfer,
          color: borderColor,
          strokeWidth: borderWidth,
        ),
        child: Container(
          color: fill,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _ChamferBorderPainter extends CustomPainter {
  final double chamfer;
  final Color color;
  final double strokeWidth;

  _ChamferBorderPainter({
    required this.chamfer,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = ChamferClipper(chamfer: chamfer).getClip(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChamferBorderPainter oldDelegate) =>
      oldDelegate.chamfer != chamfer ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
