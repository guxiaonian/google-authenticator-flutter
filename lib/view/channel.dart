import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class Channel {
  static const MethodChannel _channel =
      const MethodChannel('fairy.e.validator/qrcode');

  static Future<String> loadImageBytes({
    List<Uint8List> bytes,
    int imageWidth = 720,
    int imageHeight = 1280,
  }) async {
    return await _channel.invokeMethod(
      'imageStream',
      {
        "cameraBytes": bytes,
        "width": imageWidth,
        "height": imageHeight,
      },
    );
  }
}
