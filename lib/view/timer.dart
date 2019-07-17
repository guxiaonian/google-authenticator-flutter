import 'package:flutter/material.dart';
import 'dart:math';
import 'listener.dart';
import 'utils.dart';

class TimerWidget extends StatefulWidget {
  final ViewListener viewListener;

  const TimerWidget(this.viewListener);

  @override
  _TimerState createState() => new _TimerState(viewListener);
}

class _TimerState extends State<TimerWidget> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  AnimationController controllerTotp;
  final ViewListener viewListener;

  _TimerState(this.viewListener);

  initState() {
    super.initState();
    int time = 30 - ((Utils.currentTimeMillis() / 1000) % 30).toInt();
    print('第$time秒后开始刷新');
    double start = 2 * pi * ((30 - time) / 30);
    controller =
        AnimationController(duration: Duration(seconds: time), vsync: this);
    animation = Tween(begin: start, end: 2 * pi).animate(controller)
      ..addListener(() {
        setState(() => {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          viewListener.onSuccess();
          controllerTotp = AnimationController(
              duration: const Duration(seconds: 30), vsync: this);
          animation = Tween(begin: 0.0, end: 2 * pi).animate(controllerTotp)
            ..addListener(() {
              setState(() => {});
            })
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                controllerTotp.reset();
                viewListener.onSuccess();
              } else if (status == AnimationStatus.dismissed) {
                controllerTotp.forward();
              }
            });
          controllerTotp.forward();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      child: TimerView(animation.value),
    );
  }

  dispose() {
    controller?.dispose();
    controllerTotp?.dispose();
    super.dispose();
  }
}

class TimerView extends StatelessWidget {
  final double value;

  TimerView(this.value);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TimerPainter(value),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double value;

  TimerPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..color = Colors.white60;
    var arcPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.white10
      ..blendMode = BlendMode.src;
    Rect arcRect = Rect.fromCircle(center: Offset(12, 12), radius: 11);
    canvas.drawCircle(Offset(12, 12), 10, paint);
    canvas.drawArc(arcRect, -0.5 * pi, value, true, arcPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
