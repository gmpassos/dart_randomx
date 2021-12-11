import 'dart:io';

import 'dart:typed_data';
import 'package:base_codecs/base_codecs.dart';
import 'package:dart_randomx/dart_randomx.dart';

void printError(Object? o) {
  stderr.writeln('** $o');
}

Uint8List decodeKeyHEX(String keyHex) {
  try {
    return base16.decode(keyHex);
  } catch (e) {
    printError('ERROR decoding RandomX key.');
    printError(e);
    exit(1);
  }
}

void showUsage() {
  print('[dart_randomx]\n');
  print('USAGE:');
  print(r'  $> dart_randomx %key_hex %file');
  print('');
}

Future<void> main(List<String> args) async {
  if (args.isEmpty ||
      args.first == '-h' ||
      args.first == '--h' ||
      args.first.endsWith('help')) {
    showUsage();
    exit(0);
  }

  if (args.length < 2) {
    showUsage();
    exit(1);
  }

  var keyHex = args[0].toLowerCase().trim();
  File file = File(args[1]).absolute;

  if (!file.existsSync() || file.lengthSync() == 0) {
    printError("Can't find file: ${file.path}");
    exit(1);
  }

  var key = decodeKeyHEX(keyHex);
  print('-- RandomX key: 0x${base16.encode(key)}');

  await RandomX.loadLib();

  var randomX = RandomX();
  print('-- Created: $randomX');

  print('-- Initializing RandomX...');
  randomX.init(key);

  print('-- Processing file: ${file.path}');

  var data = file.readAsBytesSync();

  var hash = randomX.hash(data);

  print('-- Destroying $randomX');
  randomX.destroy();

  var hashHex = base16.encode(hash);
  print('-- Output hash:\n$hashHex');
}
