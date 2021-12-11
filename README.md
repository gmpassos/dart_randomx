# dart_randomx

[![pub package](https://img.shields.io/pub/v/dart_randomx.svg?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/dart_randomx)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![CI](https://img.shields.io/github/workflow/status/gmpassos/dart_randomx/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/gmpassos/dart_randomx/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/dart_randomx?logo=git&logoColor=white)](https://github.com/gmpassos/dart_randomx/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/dart_randomx/latest?logo=git&logoColor=white)](https://github.com/gmpassos/dart_randomx/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/dart_randomx?logo=git&logoColor=white)](https://github.com/gmpassos/dart_randomx/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/dart_randomx?logo=github&logoColor=white)](https://github.com/gmpassos/dart_randomx/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/dart_randomx?logo=github&logoColor=white)](https://github.com/gmpassos/dart_randomx)
[![License](https://img.shields.io/github/license/gmpassos/dart_randomx?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/dart_randomx/blob/master/LICENSE)

Dart wrapper for RandomX proof-of-work (PoW) algorithm.

## Usage

A simple usage example:

```dart
import 'dart:typed_data';
import 'package:dart_randomx/dart_randomx.dart';

Future<void> main() async {
  await RandomX.loadLib();

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

## RandomX Full Memory

The `RandomX` algorithm has 2 modes:
  - `slow`: uses less memory but is slower.
  - `fast`: faster (about 10x) but uses 2G+ of memory.

To activate the fast mode just initialize it passing `fullMemory` as `true`:

```dart
Future<void> main() async {
  await RandomX.loadLib();
  
  var randomX = RandomX();
  randomX.init(key, fullMemory: true);
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

## RandomX Configuration

The `RandomX` project recommends a different configuration for each coin,
defined by the file `RandomX/src/configuration.h`. See the configuration documentation:

- https://github.com/tevador/RandomX/blob/master/doc/configuration.md

The default configuration for this project is the same of `Monero`:
- `wrapper_randomx_library/configuration-monero.h`

**NOTE:** `RandomX` was originally developed for `Monero`.*

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

BSD-3-Clause License
