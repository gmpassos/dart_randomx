## 1.0.3

- Improved platform detection.
- `pubspec.yaml`: update description.

## 1.0.2

- Improve `init` and `destroy`.
- Reuse destroyed `ID`s.
- Added support for `hash_first`, `hash_next` and `hash_last` functions.
- Improved tests.

## 1.0.1

- Added executable: 
  - `dart_randomx`: computes a file hash.
- `RandomX`
  - Improved load of library and path resolution. 
  - Added `configuration-monero.h` to replace `RandomX/src/configuration.h`:
    - Now compatible with `Monero` mining.
  - Added support for `RANDOMX_FLAG_JIT` and `RANDOMX_FLAG_FULL_MEM`.
  - Full memory mode uses 3 threads to call `randomx_init_dataset`.
  - Compiled libraries for `Linux` (`x64`) and `MacOS` (`x64` and `arm64`).
- `README.md`: added badges ;-P
- base_codecs: ^1.0.1
- collection: ^1.15.0

## 1.0.0

- Initial version.
