import 'package:flutter/material.dart';

class ScanLine extends StatefulWidget {
  @override
  _ScanViewState createState() => new _ScanViewState();
}

class _ScanViewState extends State<ScanLine>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
//    final CurvedAnimation curve = CurvedAnimation(
//        parent: controller, curve: Curves.ease);
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
    double value = animation.value;
    return Container(
      width: 200,
      height: 200,
      padding: EdgeInsets.only(
        left: 0,
        top: value,
      ),
      child: LineView(),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class LineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(),
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..color = Colors.orange;
    canvas.drawLine(Offset(0, 0), Offset(200, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
