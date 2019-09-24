import 'base32.dart';
import "dart:typed_data";
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class Utils {
  static String getPath(String path, String issuer) {
//    return null == issuer ? path : issuer + " (" + path + ")";
    return path;
  }

  static String getNumber(String secret, bool isTotp, String counter) {
    Uint8List keys = base32.decode(secret);
    var hmacSha1 = new Hmac(sha1, keys);
    int time = isTotp ? (currentTimeMillis() / 1000) ~/ 30: int.parse(counter);

    Uint8List data = new Uint8List(8);
    int value = time;
    for (int i = 8; i-- > 0; value >>= 8) {
      data[i] = value;
    }
    Uint8List digest = hmacSha1.convert(data).bytes;
    int offset = digest[20 - 1] & 0xF;
    int truncatedHash = 0;
    for (int i = 0; i < 4; ++i) {
      truncatedHash <<= 8;
      truncatedHash |= (digest[offset + i] & 0xFF);
    }
    truncatedHash &= 0x7FFFFFFF;
    truncatedHash %= 1000000;
    print("结果为${truncatedHash.toString()}");
    return getNumberHash(truncatedHash.toString());
  }

  static String getNumberHash(String number){
    for(int i=number.length;i<6;i++){
      number="0"+number;
    }
    return number;
  }

  static int currentTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getSysStatsHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
