import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'scan.dart';
import 'dart:ui';
import 'line.dart';
import 'channel.dart';
import 'utils.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraPage(this.cameras);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;
  bool isDetecting = false;
  var mWidth, mHeight;

  void _sendToNativeOfData(var bytes) {
    Channel.loadImageBytes(
            bytes: bytes, imageWidth: mWidth, imageHeight: mHeight)
        .then((message) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (message == null) {
          setState(() {
            isDetecting = false;
          });
        } else {
          _return(message);
        }
      });
    }).catchError((error) {
      if (!mounted) {
        return;
      }
      print(error);
      setState(() {
        isDetecting = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
      return;
    }
    controller = CameraController(widget.cameras[0], ResolutionPreset.high,
        enableAudio: false);
    if (controller == null) {
      print('No CameraController is found');
      return;
    }
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;
          mWidth = img.width;
          mHeight = img.height;
          var cameraBytes = img.planes.map((plane) {
            return plane.bytes;
          }).toList();
          _sendToNativeOfData(cameraBytes);
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _return(var message) {
    Navigator.pop(context, message);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    var width = Utils.getScreenWidth(context);
    var height = Utils.getScreenHeight(context);
    var leadHeight =Utils.getSysStatsHeight(context);
    var topHeight = (height - 200) / 2;
    var leftWidth = (width - 200) / 2;

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        Container(
            child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        )),
        Align(
          alignment: FractionalOffset.center,
          child: ScanView(),
        ),
        Align(
          alignment: FractionalOffset.center,
          child: ScanLine(),
        ),
        Positioned(
            left: 0,
            top: 0,
            width: width,
            height: topHeight,
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(color: Color(0x60000000))),
                  Positioned(
                    left: 12,
                    top: leadHeight + 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => {Navigator.pop(context)},
                      child: Icon(Icons.keyboard_arrow_left, size: 36),
                    ),
                  ),
                ])),
        Positioned(
          left: 0,
          top: topHeight,
          width: leftWidth,
          height: 200,
          child: Container(decoration: BoxDecoration(color: Color(0x60000000))),
        ),
        Positioned(
          left: leftWidth + 200,
          top: topHeight,
          width: leftWidth,
          height: 200,
          child: Container(decoration: BoxDecoration(color: Color(0x60000000))),
        ),
        Positioned(
          left: 0,
          top: topHeight + 200,
          width: width,
          height: topHeight,
          child: Container(decoration: BoxDecoration(color: Color(0x60000000))),
        )
      ],
    );
  }
}
