import 'dart:typed_data';

import 'package:dart_randomx/dart_randomx.dart';
import 'package:test/test.dart';

void main() {
  group('RandomX', () {
    test('basic', () {
      //expect(awesome.isAwesome, isTrue);

      var randomX = RandomX();

      print(randomX);

      randomX.init(Uint8List.fromList([97, 98, 99, 100, 101, 102, 0]));

      var hash = randomX.hash(Uint8List.fromList([65, 66, 67, 68, 69, 0]));
      print(hash);

      expect(
          hash,
          equals([
            94,
            2,
            229,
            191,
            60,
            98,
            184,
            186,
            12,
            111,
            85,
            66,
            63,
            190,
            19,
            0,
            105,
            167,
            202,
            232,
            189,
            207,
            77,
            124,
            245,
            106,
            135,
            37,
            68,
            232,
            169,
            83
          ]));

      randomX.destroy();
    });
  });
}
