import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory, File;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import 'dart_randomx_extension.dart';

typedef FFIFunctionRandomxInit = ffi.Void Function(ffi.Int32 id,
    ffi.Pointer<ffi.Uint8> key, ffi.Int32 length, ffi.Uint8 fullMem);
typedef FunctionRandomxInit = void Function(
    int id, ffi.Pointer<ffi.Uint8> key, int length, int fullMem);

typedef FFIFunctionRandomxSizeOfHash = ffi.Int32 Function();
typedef FunctionRandomxSizeOfHash = int Function();

typedef FFIFunctionRandomxHash = ffi.Void Function(ffi.Int32 id,
    ffi.Pointer<ffi.Uint8> bytes, ffi.Int32 length, ffi.Pointer<ffi.Uint8> out);
typedef FunctionRandomxHash = void Function(int id,
    ffi.Pointer<ffi.Uint8> bytes, int length, ffi.Pointer<ffi.Uint8> out);

typedef FFIFunctionRandomxDestroy = ffi.Void Function(ffi.Int32 id);
typedef FunctionRandomxDestroy = void Function(int id);

class RandomX {
  static bool get isLibLoaded => _dynLib != null;

  static Future<bool> loadLib() async {
    if (isLibLoaded) return true;
    return await _loadLib();
  }

  static Completer<bool>? _loadLibCompleter;
  static ffi.DynamicLibrary? _dynLib;

  static Future<bool> _loadLib() async {
    var completer = _loadLibCompleter;
    if (completer != null) {
      return completer.future;
    }

    completer = _loadLibCompleter ??= Completer();

    if (completer.isCompleted) {
      return completer.future;
    }

    try {
      var libraryPath = await _getLibraryPath();
      var dynLib = ffi.DynamicLibrary.open(libraryPath);
      _mapLibFunctions(dynLib);

      _dynLib = dynLib;
      completer.complete(true);
    } catch (e, s) {
      completer.completeError(e, s);
    }

    return completer.future;
  }

  static late final FunctionRandomxInit _functionRandomxInit;
  static late final FunctionRandomxSizeOfHash _functionRandomxSizeOfHash;
  static late final FunctionRandomxHash _functionRandomxHash;
  static late final FunctionRandomxDestroy _functionRandomxDestroy;

  static void _mapLibFunctions(ffi.DynamicLibrary dynLib) {
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
  }

  static final String _libraryDirectory = 'wrapper_randomx_library';
  static final String _libraryHeaderFile = 'wrapper_randomx.h';
  static final String _libraryName = 'libwrapper_randomx';

  static Future<String> _getLibraryPath() async {
    var libExt = _getPlatformExtension();
    var wrapperLibDir = await _findWrapperLibraryDirectory();
    var libraryPath = path.join(wrapperLibDir.path, '$_libraryName$libExt');
    return libraryPath;
  }

  static Future<Directory> _findWrapperLibraryDirectory() async {
    var possiblePaths = ['.', '..', '../../', '../../../'];

    for (var p in possiblePaths) {
      var dirPath = path.join(Directory.current.path, p, _libraryDirectory);
      dirPath = path.normalize(dirPath);

      var dir = _isWrapperLibraryDirectory(dirPath);
      if (dir != null) {
        return dir;
      }
    }

    var packageUri = await Isolate.resolvePackageUri(
        Uri.parse('package:dart_randomx/dart_randomx.dart'));

    if (packageUri != null) {
      var packageFilePath = path.split(packageUri.path);
      packageFilePath.removeLast();

      var dirPath = path.joinAll([...packageFilePath, '..', _libraryDirectory]);
      dirPath = path.normalize(dirPath);

      var dir = _isWrapperLibraryDirectory(dirPath);
      if (dir != null) {
        return dir;
      }
    }

    return Directory.current;
  }

  static Directory? _isWrapperLibraryDirectory(String dirPath) {
    var dir = Directory(dirPath);
    if (dir.existsSync()) {
      var dirAbsolute = dir.absolute;
      var file = File(path.join(dirAbsolute.path, _libraryHeaderFile));
      if (file.existsSync() && file.lengthSync() > 100) {
        return dirAbsolute;
      }
    }
    return null;
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
      throw StateError(
          "Library not loaded yet. Call `RandomX.loadLib()` before instantiate a `RandomX`.");
    }

    sizeOfHash = _functionRandomxSizeOfHash();
  }

  Uint8List? _initKey;

  Uint8List? get initKey => _initKey;

  bool equalsInitKey(Uint8List key) {
    var initKey = _initKey;
    if (initKey == null) {
      return false;
    }

    return initKey.equals(key);
  }

  bool? _fullMemory;

  bool? get fullMemory => _fullMemory;

  void init(Uint8List key, {bool fullMemory = false}) {
    _initKey = UnmodifiableUint8ListView(Uint8List.fromList(key));
    var keyPointer = key.asPointer();
    _functionRandomxInit(id, keyPointer, key.length, fullMemory ? 1 : 0);
    _fullMemory = fullMemory;
    keyPointer.free();
  }

  Uint8List createHashBytesArray() => Uint8List(sizeOfHash);

  ffi.Pointer<ffi.Uint8>? _hashInputPointer;

  int _hashInputPointerLength = 0;

  ffi.Pointer<ffi.Uint8> _getInputPointer(int length) {
    if (_hashInputPointerLength < length) {
      var prevPointer = _hashInputPointer;
      if (prevPointer != null) {
        prevPointer.free();
        _hashInputPointer = null;
      }

      var inputPointer = createBytesPointer(length);

      _hashInputPointer = inputPointer;
      _hashInputPointerLength = length;

      return inputPointer;
    } else {
      return _hashInputPointer!;
    }
  }

  ffi.Pointer<ffi.Uint8>? _hashOutputPointer;

  ffi.Pointer<ffi.Uint8> _getOutputPointer() =>
      _hashOutputPointer ??= createBytesPointer(sizeOfHash);

  void hashTo(Uint8List bytes, Uint8List output) {
    var inputPointer = _getInputPointer(bytes.length);
    inputPointer.setBytes(bytes);

    var outputPoints = _getOutputPointer();

    _functionRandomxHash(id, inputPointer, bytes.length, outputPoints);

    final outBytes = outputPoints.asTypedList(sizeOfHash);
    output.setAll(0, outBytes);
  }

  Uint8List hash(Uint8List bytes) {
    var output = createHashBytesArray();
    hashTo(bytes, output);
    return output;
  }

  void destroy() => _functionRandomxDestroy(id);

  @override
  String toString() =>
      'RandomX{ id: $id, fullMemory: $fullMemory, sizeOfHash: $sizeOfHash, initKey: ${initKey?.toHex()} }';
}

ffi.Pointer<ffi.Uint8> createBytesPointer(int length) =>
    malloc.allocate<ffi.Uint8>(ffi.sizeOf<ffi.Uint8>() * length);

extension _Uint8ListExtension on Uint8List {
  ffi.Pointer<ffi.Uint8> createPointer() => createBytesPointer(length);

  /// Allocates a pointer filled with the Uint8List data.
  ffi.Pointer<ffi.Uint8> asPointer() {
    final pointer = createPointer();
    pointer.setBytes(this);
    return pointer;
  }
}

extension _PointerUint8Extension on ffi.Pointer<ffi.Uint8> {
  void setBytes(Uint8List bytes, [int offset = 0]) {
    final pointerBytes = asTypedList(bytes.length);
    pointerBytes.setAll(offset, bytes);
  }

  void free() => malloc.free(this);
}
