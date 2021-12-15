import 'dart:io';
import 'dart:typed_data';

import 'package:dart_randomx/dart_randomx.dart';
import 'package:statistics/statistics.dart';
import 'package:test/test.dart';

const hashes = {
  '5E02E5BF3C62B8BA0C6F55423FBE130069A7CAE8BDCF4D7CF56A872544E8A953':
      'F75201F07E7ADDFE76D6E1E9EA7A2D73ED8F0B842A83FDD4207A0626BE6904FD',
  'E251850147BAF451C5FBE6FCFF1036CBAD3E879F30ADCE070B6254FC8C7F2CE6':
      '81A32539A6A14EE30B24F70C91C7C913C77BD812616E9B0A2698403EF0DA84E6',
  'F75201F07E7ADDFE76D6E1E9EA7A2D73ED8F0B842A83FDD4207A0626BE6904FD':
      'BFB82AA3E32B86111BA5593C47D55518AB7862905EA6C79C0FFE57C1CB77ABC7',
  '81A32539A6A14EE30B24F70C91C7C913C77BD812616E9B0A2698403EF0DA84E6':
      'EBA2265D759F8CF9C579A97EC1DF71654573FC2E3B9943BE4658F5274D0D392B',
  'BFB82AA3E32B86111BA5593C47D55518AB7862905EA6C79C0FFE57C1CB77ABC7':
      '00059F688D9E3795C2F4EFD82C3A0EC7D47096E276635F04C9ACDAC6F1A9AD1B',
  'EBA2265D759F8CF9C579A97EC1DF71654573FC2E3B9943BE4658F5274D0D392B':
      '4C08FF07D60D8BCC5B5D6990499A6A1E433DCA2290D67C74141195B35DF59FCD',
  '00059F688D9E3795C2F4EFD82C3A0EC7D47096E276635F04C9ACDAC6F1A9AD1B':
      '6066AAE93C7E3815032B3D7CC5B1834DE438BEC2B68BB8B229C10E1372DA49F6',
  '4C08FF07D60D8BCC5B5D6990499A6A1E433DCA2290D67C74141195B35DF59FCD':
      'B7DF73E1F5D7BAFAECF6DB44D22F381EA54062667AC3455E1B64E57A8078F0C2',
  '6066AAE93C7E3815032B3D7CC5B1834DE438BEC2B68BB8B229C10E1372DA49F6':
      '93AD865D91455FE2ED99831B63609A2201EDFFD1D174098946A24206ADFE8CD7',
  'B7DF73E1F5D7BAFAECF6DB44D22F381EA54062667AC3455E1B64E57A8078F0C2':
      '0413CE767F5B6BA6117DAECB57B9E1EA64F9826B93A84BF74F2A7AF2D417F1A4',
  '93AD865D91455FE2ED99831B63609A2201EDFFD1D174098946A24206ADFE8CD7':
      '62AB90B2EC012F4316277B7C2F7C3EE20D0D551457541D4C8EC55483C10938D0',
  '0413CE767F5B6BA6117DAECB57B9E1EA64F9826B93A84BF74F2A7AF2D417F1A4':
      '38AD5BEFFBC2E4F494BA8E84523B029694B13AB05B7A3C54A12DDF269FFDD943',
  '62AB90B2EC012F4316277B7C2F7C3EE20D0D551457541D4C8EC55483C10938D0':
      '37AB8B86AC151237C92588B90590E6663375F26BE7F4C36C26B318AF8E8FFA01',
  '38AD5BEFFBC2E4F494BA8E84523B029694B13AB05B7A3C54A12DDF269FFDD943':
      '70AFE5808D456A64EEE62A4868DCB3999EB9D8CD8E40EFAFA7ABD844B3512969',
  '37AB8B86AC151237C92588B90590E6663375F26BE7F4C36C26B318AF8E8FFA01':
      'AF99FF6A1D0FDC6F4FDB755C08D94308717A0CA24D7B762191F2452D4A38EE7B',
  '70AFE5808D456A64EEE62A4868DCB3999EB9D8CD8E40EFAFA7ABD844B3512969':
      '6AA7983EF806E894630021D5A5960E326FE33F78A78E947AB8A34819822ED5B7',
  'AF99FF6A1D0FDC6F4FDB755C08D94308717A0CA24D7B762191F2452D4A38EE7B':
      'B8A1AA89AF59458FA736C4D374523732A9E2942F5252BD1F7AE257D1AC640F28',
};

void main() {
  group('RandomX', () {
    final initKey = Uint8List.fromList([97, 98, 99, 100, 101, 102, 0]);

    setUp(() async {
      print(
          '=================================================================');
      print('Platform.operatingSystem: ${Platform.operatingSystem}');
      print(
          'Platform.operatingSystemVersion: ${Platform.operatingSystemVersion}');

      expect(await RandomX.loadLib(), isTrue);

      print('RandomX.loadedLibraryPath: ${RandomX.loadedLibraryPath}');
    });

    test('basic', () {
      var randomX = RandomX();

      print(randomX);

      randomX.init(initKey);

      expect(randomX.initKey, equals(initKey));
      expect(randomX.isInitialized, isTrue);
      expect(randomX.isDestroyed, isFalse);

      _testHashes(randomX);

      print('-- Destroying: $randomX...');
      randomX.destroy();

      expect(randomX.isDestroyed, isTrue);
    });

    test('multiple', () {
      var randomX1 = RandomX();
      var randomX2 = RandomX();
      var randomX3 = RandomX();

      print(randomX1);
      print(randomX2);
      print(randomX3);

      randomX1.init(initKey);
      randomX2.init(initKey);
      randomX3.init(initKey);

      _testHashes(randomX1);
      _testHashes(randomX2);
      _testHashes(randomX3);

      print('-- Destroying: $randomX1...');
      randomX1.destroy();
      print('-- Destroying: $randomX2...');
      randomX2.destroy();
      print('-- Destroying: $randomX3...');
      randomX3.destroy();
    });

    test(
      'fullMemory',
      () {
        var randomX = RandomX();

        print(randomX);

        print('-- RandomX initializing full memory...');
        randomX.init(Uint8List.fromList(initKey), fullMemory: true);

        _testHashes(randomX);

        print('-- Destroying: $randomX...');
        randomX.destroy();
      },
      //skip: true,
    );
  });
}

void _testHashes(RandomX randomX) {
  {
    var hash = randomX.hash(Uint8List.fromList([65, 66, 67, 68, 69, 0]));
    print(hash);

    var expectedHashHex =
        '5E02E5BF3C62B8BA0C6F55423FBE130069A7CAE8BDCF4D7CF56A872544E8A953';
    print(expectedHashHex);

    expect(hash.toHex(), equals(expectedHashHex));
    expect(hash, equals(expectedHashHex.decodeHex()));
  }

  print('-----------------------------------------------------------------');

  {
    var hash = randomX.hash(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 0]));
    print(hash);

    var expectedHashHex =
        'E251850147BAF451C5FBE6FCFF1036CBAD3E879F30ADCE070B6254FC8C7F2CE6';
    print(expectedHashHex);

    expect(hash.toHex(), equals(expectedHashHex));
    expect(hash, equals(expectedHashHex.decodeHex()));
  }

  print('-----------------------------------------------------------------');

  {
    for (var e in hashes.entries) {
      var input = e.key.decodeHex();
      var expectedHash = e.value.decodeHex();

      print('--- ${input.toHex()} ...');
      var hash = randomX.hash(input);
      print('  > ${hash.toHex()}\n');

      expect(hash.toHex(), equals(expectedHash.toHex()));
    }
  }

  print('-----------------------------------------------------------------');

  {
    Uint8List? prevExpected;

    var output = randomX.createHashBytesArray();

    for (var e in hashes.entries) {
      var input = e.key.decodeHex();
      var expectedHash = e.value.decodeHex();

      print('--- ${input.toHex()} ...');

      if (prevExpected == null) {
        randomX.hashFirst(input);
      } else {
        randomX.hashNext(input, output);

        print('prv> ${output.toHex()}\n');
        expect(output.toHex(), equals(prevExpected.toHex()));
      }

      prevExpected = expectedHash;
    }

    randomX.hashLast(output);
    print('lst> ${output.toHex()}\n');
    expect(output.toHex(), equals(prevExpected!.toHex()));
  }
}
