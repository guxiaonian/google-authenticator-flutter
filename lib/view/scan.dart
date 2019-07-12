import 'package:flutter/material.dart';

class ScanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(200, 200),
      painter: ScanPainter(),
    );
  }
}

class ScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 5
      ..color = Colors.red;
    var rPaint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke
      ..color = Colors.grey;
    canvas.drawRect(Offset.zero & size, rPaint);
    canvas.drawLine(Offset(0, 2), Offset(20, 2), paint);
    canvas.drawLine(Offset(2, 0), Offset(2, 20), paint);
    canvas.drawLine(Offset(size.width, 2), Offset(size.width - 20, 2), paint);
    canvas.drawLine(
        Offset(size.width - 2, 0), Offset(size.width - 2, 20), paint);
    canvas.drawLine(
        Offset(0, size.height - 2), Offset(20, size.height - 2), paint);
    canvas.drawLine(Offset(2, size.height), Offset(2, size.height - 20), paint);
    canvas.drawLine(Offset(size.width - 2, size.height),
        Offset(size.width - 2, size.height - 20), paint);
    canvas.drawLine(Offset(size.width, size.height - 2),
        Offset(size.width - 20, size.height - 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
