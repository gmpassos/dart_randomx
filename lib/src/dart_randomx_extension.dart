import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart';
import 'package:collection/collection.dart';

extension Uint8ListExtension on Uint8List {
  static final ListEquality<int> _listIntEquality = ListEquality<int>();

  bool equals(Uint8List other) => _listIntEquality.equals(this, other);

  Uint8List subView([int offset = 0, int? length]) {
    length ??= this.length - offset;
    return buffer.asUint8List(offset, length);
  }

  Uint8List subViewTail(int tailLength) {
    var length = this.length;
    var offset = length - tailLength;
    var lng = length - offset;
    return subView(offset, lng);
  }

  ByteData asByteData() => buffer.asByteData(offsetInBytes, lengthInBytes);

  Uint8List copy() => Uint8List.fromList(this);

  Uint8List reverse() => Uint8List.fromList(reversed.toList());

  String toHex({Endian endian = Endian.big}) {
    return endian == Endian.big ? toHexBigEndian() : toHexLittleEndian();
  }

  String toHexBigEndian() => base16.encode(this);
  String toHexLittleEndian() => base16.encode(reverse());
}

extension IntExtension on int {
  Uint8List toUint8List32() {
    var bs = Uint8List(4);
    var data = bs.asByteData();
    data.setUint32(0, this);
    return bs;
  }

  Uint8List toUint8List64() {
    var bs = Uint8List(8);
    var data = bs.asByteData();
    data.setUint64(0, this);
    return bs;
  }

  String toHex32() => toUint8List32().toHex();
  String toHex64() => toUint8List64().toHex();

  BigInt get asBigInt => BigInt.from(this);

  String toStringPadded(int width) => toString().padLeft(width, '0');
}

extension DoubleExtension on double {
  String toPercentageString({int fractionDigits = 2, String suffix = '%'}) =>
      (this * 100).toStringAsFixed(fractionDigits) + suffix;
}

extension BigIntExtension on BigInt {
  String toHex() => toRadixString(16);

  String toHex32() => toRadixString(16).padLeft(32, '0');
  String toHex64() => toRadixString(16).padLeft(64, '0');
}

extension StringExtension on String {
  Uint8List decodeHex() => base16.decode(this);

  BigInt toBigInt() => BigInt.parse(this);

  BigInt toBigIntFromHex() => BigInt.parse(this, radix: 16);
}
