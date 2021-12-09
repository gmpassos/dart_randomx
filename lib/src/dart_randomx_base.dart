import 'dart:typed_data';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

typedef FFIFunctionRandomxInit = ffi.Void Function(
    ffi.Int32 id, ffi.Pointer<ffi.Uint8> key, ffi.Int32 length);
typedef FunctionRandomxInit = void Function(
    int id, ffi.Pointer<ffi.Uint8> key, int length);

typedef FFIFunctionRandomxSizeOfHash = ffi.Int32 Function();
typedef FunctionRandomxSizeOfHash = int Function();

typedef FFIFunctionRandomxHash = ffi.Void Function(ffi.Int32 id,
    ffi.Pointer<ffi.Uint8> bytes, ffi.Int32 length, ffi.Pointer<ffi.Uint8> out);
typedef FunctionRandomxHash = void Function(int id,
    ffi.Pointer<ffi.Uint8> bytes, int length, ffi.Pointer<ffi.Uint8> out);

typedef FFIFunctionRandomxDestroy = ffi.Void Function(ffi.Int32 id);
typedef FunctionRandomxDestroy = void Function(int id);

class RandomX {
  static ffi.DynamicLibrary? _dynLib;

  static bool get isLibLoaded => (_dynLib ??= _loadLib()) != null;

  static late final FunctionRandomxInit _functionRandomxInit;
  static late final FunctionRandomxSizeOfHash _functionRandomxSizeOfHash;
  static late final FunctionRandomxHash _functionRandomxHash;
  static late final FunctionRandomxDestroy _functionRandomxDestroy;

  static ffi.DynamicLibrary? _loadLib() {
    var libraryPath = _getLibraryPath();
    var dynLib = ffi.DynamicLibrary.open(libraryPath);

    _functionRandomxInit =
        dynLib.lookupFunction<FFIFunctionRandomxInit, FunctionRandomxInit>(
            'wrapper_randomx_init');
    _functionRandomxSizeOfHash = dynLib.lookupFunction<
        FFIFunctionRandomxSizeOfHash,
        FunctionRandomxSizeOfHash>('wrapper_randomx_size_of_hash');
    _functionRandomxHash =
        dynLib.lookupFunction<FFIFunctionRandomxHash, FunctionRandomxHash>(
            'wrapper_randomx_hash');
    _functionRandomxDestroy = dynLib.lookupFunction<FFIFunctionRandomxDestroy,
        FunctionRandomxDestroy>('wrapper_randomx_destroy');

    return dynLib;
  }

  static final String _libraryDirectory = 'wrapper_randomx_library';
  static final String _libraryName = 'libwrapper_randomx';

  static String _getLibraryPath() {
    var libExt = _getPlatformExtension();
    var libraryPath = path.join(
        Directory.current.path, _libraryDirectory, '$_libraryName$libExt');
    return libraryPath;
  }

  static String _getPlatformExtension() {
    if (Platform.isLinux) return '.so';
    if (Platform.isMacOS) return '.dylib';
    if (Platform.isWindows) return '.dll';
    throw 'Unsupported platform ${Platform.operatingSystem}';
  }

  static int _idCount = 0;

  final int id = ++_idCount;
  late final int sizeOfHash;

  RandomX() {
    if (!isLibLoaded) {
      throw StateError("Can't loading lib");
    }

    sizeOfHash = _functionRandomxSizeOfHash();
  }

  void init(Uint8List key) =>
      _functionRandomxInit(id, key.allocatePointer(), key.length);

  Uint8List hash(Uint8List bytes) {
    var out = Uint8List(sizeOfHash);
    var outPtr = out.allocatePointer();
    _functionRandomxHash(id, bytes.allocatePointer(), bytes.length, outPtr);
    final outBytes = outPtr.asTypedList(sizeOfHash);
    out.setAll(0, outBytes);
    return out;
  }

  void destroy() => _functionRandomxDestroy(id);

  @override
  String toString() => 'RandomX{id: $id, sizeOfHash: $sizeOfHash}';
}

extension _Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  ffi.Pointer<ffi.Uint8> allocatePointer() {
    final blob = malloc.allocate<ffi.Uint8>(ffi.sizeOf<ffi.Uint8>() * length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}
