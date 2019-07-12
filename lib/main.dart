import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'view/camera.dart';

List<CameraDescription> cameras;

void main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.code + e.description);
  }
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '验证器',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MyHomePage(cameras),
    );
  }
}
