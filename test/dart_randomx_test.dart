import 'dart:typed_data';

import 'package:dart_randomx/dart_randomx.dart';
import 'package:dart_randomx/src/dart_randomx_extension.dart';
import 'package:test/test.dart';

void main() {
  group('RandomX', () {
    setUp(() async {
      expect(await RandomX.loadLib(), isTrue);
    });

    test('basic', () {
      var randomX = RandomX();

      print(randomX);

      randomX.init(Uint8List.fromList([97, 98, 99, 100, 101, 102, 0]));

      var hash = randomX.hash(Uint8List.fromList([65, 66, 67, 68, 69, 0]));
      print(hash);

      var expectedHashHex =
          '5E02E5BF3C62B8BA0C6F55423FBE130069A7CAE8BDCF4D7CF56A872544E8A953';

      var expectHash = expectedHashHex.decodeHex();
      print(expectHash.toHex());

      expect(expectHash.toHex(), equals(expectedHashHex));

      expect(hash, equals(expectHash));

      randomX.destroy();
    });

    test('fullMemory', () {
      var randomX = RandomX();

      print(randomX);

      randomX.init(Uint8List.fromList([97, 98, 99, 100, 101, 102, 0]),
          fullMemory: true);

      var hash = randomX.hash(Uint8List.fromList([65, 66, 67, 68, 69, 0]));
      print(hash);

      var expectedHashHex =
          '5E02E5BF3C62B8BA0C6F55423FBE130069A7CAE8BDCF4D7CF56A872544E8A953';

      var expectHash = expectedHashHex.decodeHex();
      print(expectHash.toHex());

      expect(expectHash.toHex(), equals(expectedHashHex));

      expect(hash, equals(expectHash));

      randomX.destroy();
    });
  });
}
