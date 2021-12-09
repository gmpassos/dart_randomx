# dart_randomx

Dart wrapper for RandomX proof-of-work (PoW) algorithm.

## Usage

A simple usage example:

```dart
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
```

## Project Build

See the script `build-ffi-lib.sh` to build the libraries:

- `randomx`: the RandomX `PoW` algorithm.
- `wrapper_randomx`: [dart:ffi][dart_ffi] wrapper of lib `randomx`.

The directory `wrapper_randomx_library` has the source code for the
[dart:ffi][dart_ffi] wrapper and the build scripts:

- `build-librandomx.sh`:
  
   Will clone the `RandomX` project, build it and place the library file
   `librandomx.a` at `wrapper_randomx_library/` to then build the wrapper.


- `build-wrapper.sh`:

   Builds the wrapper, linking with `librandomx.a`.


**NOTE:** *This process was tested on `MaxOS` and `Ubuntu`.*

[dart_ffi]: https://dart.dev/guides/libraries/c-interop

## RandomX Project

The RandomX proof-of-work (PoW) algorithm can be found at:

- https://github.com/tevador/RandomX

**NOTE:** *The script `build-librandomx.sh` automatically clones and builds it.*

# Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

BSD-3-Clause License
