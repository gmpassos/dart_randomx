import 'dart:typed_data';
import 'package:dart_randomx/dart_randomx.dart';

void main() {
  var randomX = RandomX();

  print(randomX);

  var key = Uint8List.fromList([97, 98, 99, 100, 101, 102, 0]);
  randomX.init(key);

  var data = Uint8List.fromList([65, 66, 67, 68, 69, 0]);

  var hash = randomX.hash(data);
  print(hash);

  randomX.destroy();
}
