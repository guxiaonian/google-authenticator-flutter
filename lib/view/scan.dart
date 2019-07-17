import 'package:flutter/material.dart';

class ScanView extends StatefulWidget {
  @override
  _ScanViewState createState() => new _ScanViewState();
}

class _ScanViewState extends State<ScanView>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
//    final CurvedAnimation curve =
//        CurvedAnimation(parent: controller, curve: Curves.ease);
    animation = Tween(begin: 0.0, end: 200.0).animate(controller)
      ..addListener(() {
        setState(() => {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: LineView(animation.value),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class LineView extends StatelessWidget {
  final double value;

  LineView(this.value);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(value),
    );
  }
}

class LinePainter extends CustomPainter {
  final double value;

  LinePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    var lPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..color = Colors.orange;

    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 5
      ..color = Colors.red;
    var rPaint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke
      ..color = Colors.grey;

    canvas.drawLine(Offset(0, value), Offset(200, value), lPaint);

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
    return true;
  }
}
