import 'package:flutter/material.dart';
import 'dart:async';

class ToastHelper {
  static void showToast(BuildContext context, String text) {
    const style = TextStyle(
        color: Colors.black, fontSize: 12.0, decoration: TextDecoration.none);

    Widget widget = Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned(
          bottom: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            padding:const EdgeInsets.all(10.0),
            child: Text(
              text,
              style: style,
            ),
          ),
        )
      ],
    );
    var entry = OverlayEntry(
      builder: (_) => widget,
    );

    Overlay.of(context).insert(entry);

    Timer(const Duration(seconds: 2), () {
      entry?.remove();
    });
  }
}
