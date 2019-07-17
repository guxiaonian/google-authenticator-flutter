import "dart:typed_data";

/**
 * copy from https://github.com/Daegalus/dart-base32/blob/master/lib/base32.dart
 * thanks
 */
class base32 {
  /**
   * Takes in a [byteList] converts it to a Uint8List so that I can run
   * bit operations on it, then outputs a [String] representation of the
   * base32.
   */
  static String encode(List<int> bytesList) {
    var bytes = new Uint8List(bytesList.length);
    bytes.setRange(0, bytes.length, bytesList, 0);
    int i = 0, index = 0, digit = 0;
    int currByte, nextByte;
    String base32 = '';

    while (i < bytes.length) {
      currByte = bytes[i];

      if (index > 3) {
        if ((i + 1) < bytes.length) {
          nextByte = bytes[i + 1];
        } else {
          nextByte = 0;
        }

        digit = currByte & (0xFF >> index);
        index = (index + 5) % 8;
        digit <<= index;
        digit |= nextByte >> (8 - index);
        i++;
      } else {
        digit = (currByte >> (8 - (index + 5)) & 0x1F);
        index = (index + 5) % 8;
        if (index == 0) {
          i++;
        }
      }
      base32 = base32 + _base32Chars[digit];
    }
    return base32;
  }

  /**
   * Takes in a [hex] string, converts the string to a byte list
   * and runs a normal encode() on it. Returning a [String] representation
   * of the base32.
   */
  static String encodeHexString(String hex) {
    var bytes = _hexStringToBytes(hex);
    return encode(bytes);
  }

  /**
   * Takes in a [base32] string and decodes it back to a [Uint8List] that can be
   * converted to a hex string using Crypto.bytesToHex()
   */
  static Uint8List decode(String base32) {
    int index = 0, lookup, offset = 0, digit;
    Uint8List bytes = new Uint8List(base32.length * 5 ~/ 8);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }

    for (int i = 0; i < base32.length; i++) {
      lookup = base32.codeUnitAt(i) - '0'.codeUnitAt(0);
      if (lookup < 0 || lookup >= _base32Lookup.length) {
        continue;
      }

      digit = _base32Lookup[lookup];
      if (digit == 0xFF) {
        continue;
      }

      if (index <= 3) {
        index = (index + 5) % 8;
        if (index == 0) {
          bytes[offset] |= digit;
          offset++;
          if (offset >= bytes.length) {
            break;
          }
        } else {
          bytes[offset] |= digit << (8 - index);
        }
      } else {
        index = (index + 5) % 8;
        bytes[offset] |= (digit >> index);
        offset++;

        if (offset >= bytes.length) {
          break;
        }

        bytes[offset] |= digit << (8 - index);
      }
    }
    return bytes;
  }

  static Uint8List _hexStringToBytes(hex) {
    int i = 0;
    Uint8List bytes = new Uint8List(hex.length ~/ 2);
    final RegExp regex = new RegExp('[0-9a-f]{2}');
    for (Match match in regex.allMatches(hex.toLowerCase())) {
      bytes[i++] = int.parse(
          hex.toLowerCase().substring(match.start, match.end),
          radix: 16);
    }
    return bytes;
  }

  static const _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const _base32Lookup = const [
    0xFF, 0xFF, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E,
    0x1F, // '0', '1', '2', '3', '4', '5', '6', '7'
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, // '8', '9', ':', ';', '<', '=', '>', '?'
    0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
    0x06, // '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G'
    0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D,
    0x0E, // 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
    0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
    0x16, // 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
    0x17, 0x18, 0x19, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, // 'X', 'Y', 'Z', '[', '\', ']', '^', '_'
    0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
    0x06, // '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g'
    0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D,
    0x0E, // 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
    0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
    0x16, // 'p', 'q', 'r', 's', 't', 'u', 'v', 'w'
    0x17, 0x18, 0x19, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF // 'x', 'y', 'z', '{', '|', '}', '~', 'DEL'
  ];
}
