import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform, Process;
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

typedef FFIFunctionRandomxHashFirst = ffi.Void Function(
    ffi.Int32 id, ffi.Pointer<ffi.Uint8> bytes, ffi.Int32 length);
typedef FunctionRandomxHashFirst = void Function(
    int id, ffi.Pointer<ffi.Uint8> bytes, int length);

typedef FFIFunctionRandomxHashNext = ffi.Void Function(
    ffi.Int32 id,
    ffi.Pointer<ffi.Uint8> bytes,
    ffi.Int32 length,
    ffi.Pointer<ffi.Uint8> prevOut);
typedef FunctionRandomxHashNext = void Function(int id,
    ffi.Pointer<ffi.Uint8> bytes, int length, ffi.Pointer<ffi.Uint8> prevOut);

typedef FFIFunctionRandomxHashLast = ffi.Void Function(
    ffi.Int32 id, ffi.Pointer<ffi.Uint8> prevOut);
typedef FunctionRandomxHashLast = void Function(
    int id, ffi.Pointer<ffi.Uint8> prevOut);

typedef FFIFunctionRandomxDestroy = ffi.Void Function(ffi.Int32 id);
typedef FunctionRandomxDestroy = void Function(int id);

/// Dart `RandomX` library wrapper.
class RandomX {
  /// Returns `true` if the library is already loaded.
  static bool get isLibLoaded => _dynLib != null;

  /// Returns the path of the loaded library.
  ///
  /// See [isLibLoaded] as [loadLib].
  static String? get loadedLibraryPath => _dynLibPath;

  /// Loads the wrapper library.
  static Future<bool> loadLib() async {
    if (isLibLoaded) return true;
    return await _loadLib();
  }

  static Completer<bool>? _loadLibCompleter;
  static ffi.DynamicLibrary? _dynLib;
  static String? _dynLibPath;

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
      var libraryPaths = await _getLibraryPath();
      ffi.DynamicLibrary? dynLib;
      String? dynLibPath;

      Object? error;
      for (var libPath in libraryPaths) {
        try {
          dynLib = ffi.DynamicLibrary.open(libPath);
          dynLibPath = libPath;
          break;
        } catch (e) {
          print('$libPath >> $e');
          error = e;
        }
      }

      if (dynLib == null) {
        throw StateError("Can't find library at $libraryPaths > $error");
      }

      _mapLibFunctions(dynLib);

      _dynLib = dynLib;
      _dynLibPath = dynLibPath;
      completer.complete(true);
    } catch (e, s) {
      completer.completeError(e, s);
    }

    return completer.future;
  }

  static late final FunctionRandomxInit _functionRandomxInit;
  static late final FunctionRandomxSizeOfHash _functionRandomxSizeOfHash;
  static late final FunctionRandomxHash _functionRandomxHash;
  static late final FunctionRandomxHashFirst _functionRandomxHashFirst;
  static late final FunctionRandomxHashNext _functionRandomxHashNext;
  static late final FunctionRandomxHashLast _functionRandomxHashLast;
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
    _functionRandomxHashFirst = dynLib.lookupFunction<
        FFIFunctionRandomxHashFirst,
        FunctionRandomxHashFirst>('wrapper_randomx_hash_first');
    _functionRandomxHashNext = dynLib.lookupFunction<FFIFunctionRandomxHashNext,
        FunctionRandomxHashNext>('wrapper_randomx_hash_next');
    _functionRandomxHashLast = dynLib.lookupFunction<FFIFunctionRandomxHashLast,
        FunctionRandomxHashLast>('wrapper_randomx_hash_last');
    _functionRandomxDestroy = dynLib.lookupFunction<FFIFunctionRandomxDestroy,
        FunctionRandomxDestroy>('wrapper_randomx_destroy');
  }

  static final String _libraryDirectory = 'wrapper_randomx_library';
  static final String _libraryHeaderFile = 'wrapper_randomx.h';
  static final String _libraryName = 'libwrapper_randomx';

  static Future<List<String>> _getLibraryPath() async {
    var libExtensions = _getPlatformExtensions();
    var wrapperLibDir = await _findWrapperLibraryDirectory();
    var libraryPaths = libExtensions
        .map((ext) => path.join(wrapperLibDir.path, '$_libraryName$ext'))
        .toList();
    return libraryPaths;
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

  static List<String> _getPlatformExtensions() {
    if (Platform.isLinux) {
      return ['.so'];
    } else if (Platform.isMacOS) {
      var arm64 = isMacOSArm64();
      var main = arm64 ? '-arm64.dylib' : '-x64.dylib';
      return [main, '.dylib'];
    } else if (Platform.isWindows) {
      return ['.dll'];
    }

    throw 'Unsupported platform ${Platform.operatingSystem}';
  }

  static int _idCount = 0;
  static final List<int> _destroyedIDs = <int>[];

  static int _getFreeID() {
    if (_destroyedIDs.isNotEmpty) {
      var id = _destroyedIDs.removeAt(0);
      return id;
    }
    return ++_idCount;
  }

  final int id = _getFreeID();

  late final int sizeOfHash;

  /// [RandomX] default constructor.
  ///
  /// Call [RandomX.loadLib] before instantiate.
  RandomX() {
    if (!isLibLoaded) {
      throw StateError(
          "Library not loaded yet. Call `RandomX.loadLib()` before instantiate a `RandomX`.");
    }

    sizeOfHash = _functionRandomxSizeOfHash();
  }

  Uint8List? _initKey;

  Uint8List? get initKey => _initKey;

  /// Returns `true` if [key] equals to [initKey].
  bool equalsInitKey(Uint8List key) {
    var initKey = _initKey;
    if (initKey == null) {
      return false;
    }

    return initKey.equals(key);
  }

  bool? _fullMemory;

  /// Returns `true` if [init] was called with `fullMemory`.
  bool? get fullMemory => _fullMemory;

  bool _initialized = false;

  /// Returns `true` if this instance is already initialized.
  bool get isInitialized => _initialized;

  /// Initializes the `RandomX` instance with [key].
  ///
  /// - [fullMemory] if `true` will use 2G+ of memory (fast mode).
  void init(Uint8List key, {bool fullMemory = false}) {
    if (_initialized) return;
    _initialized = true;

    _initKey = UnmodifiableUint8ListView(Uint8List.fromList(key));
    var keyPointer = key.asPointer();
    _functionRandomxInit(id, keyPointer, key.length, fullMemory ? 1 : 0);
    _fullMemory = fullMemory;
    keyPointer.free();
  }

  /// Creates a [Uint8List] of the size of the [hash] output ([sizeOfHash]).
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

  /// Hash [bytes] and puts the result into [output].
  void hashTo(Uint8List bytes, Uint8List output) {
    if (_destroyed) {
      _throwAlreadyDestroyed();
    }

    var inputPointer = _getInputPointer(bytes.length);
    inputPointer.setBytes(bytes);

    var outputPointers = _getOutputPointer();

    _functionRandomxHash(id, inputPointer, bytes.length, outputPointers);

    final outBytes = outputPointers.asTypedList(sizeOfHash);
    output.setAll(0, outBytes);
  }

  void _throwAlreadyDestroyed() {
    throw StateError("Can't hash: already destroyed instance!");
  }

  /// Hash [bytes] and returns the result as a [Uint8List].
  Uint8List hash(Uint8List bytes) {
    var output = createHashBytesArray();
    hashTo(bytes, output);
    return output;
  }

  /// The [RandomX] `hash_first` function.
  void hashFirst(Uint8List bytes) {
    if (_destroyed) {
      _throwAlreadyDestroyed();
    }

    var inputPointer = _getInputPointer(bytes.length);
    inputPointer.setBytes(bytes);

    _functionRandomxHashFirst(id, inputPointer, bytes.length);
  }

  /// The [RandomX] `hash_next` function.
  void hashNext(Uint8List bytes, Uint8List prevOutput) {
    if (_destroyed) {
      _throwAlreadyDestroyed();
    }

    var inputPointer = _getInputPointer(bytes.length);
    inputPointer.setBytes(bytes);

    var outputPointers = _getOutputPointer();

    _functionRandomxHashNext(id, inputPointer, bytes.length, outputPointers);

    final outBytes = outputPointers.asTypedList(sizeOfHash);
    prevOutput.setAll(0, outBytes);
  }

  /// The [RandomX] `hash_last` function.
  void hashLast(Uint8List prevOutput) {
    if (_destroyed) {
      _throwAlreadyDestroyed();
    }

    var outputPointers = _getOutputPointer();

    _functionRandomxHashLast(id, outputPointers);

    final outBytes = outputPointers.asTypedList(sizeOfHash);
    prevOutput.setAll(0, outBytes);
  }

  bool _destroyed = false;

  /// Returns `true` if this instance is already destroyed.
  bool get isDestroyed => _destroyed;

  /// Destroys `this` [RandomX] instance resources.
  void destroy() {
    if (_destroyed) return;
    _destroyed = true;

    _functionRandomxDestroy(id);
    _destroyedIDs.add(id);
  }

  /// Returns the [platformOS] and [platformArchitecture].
  String get platform => '$platformOS/$platformArchitecture';

  /// The current Platform OS name.
  String get platformOS {
    if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else {
      throw StateError('Unknown platform');
    }
  }

  /// The current Platform architecture name.
  String get platformArchitecture {
    if (Platform.isWindows) {
      return 'x86';
    } else if (Platform.isLinux) {
      return _runUnameM()!;
    } else if (Platform.isMacOS) {
      return _runUnameM()!;
    } else {
      throw StateError('Unknown platform');
    }
  }

  /// Returns `true` if this is a `macOS` `arm64`.
  static bool isMacOSArm64() {
    if (!Platform.isMacOS) return false;
    var output = _runUnameM()!;
    return output == 'arm64';
  }

  static String? _runUnameM() {
    if (!Platform.isLinux && !Platform.isMacOS) return null;
    return _runProcess(['/usr/bin/uname', '/bin/uname'], ['-m'], 0)
        .toLowerCase()
        .trim();
  }

  static String _runProcess(
      List<String> possibleCMDs, List<String> args, int exitCode) {
    Object? error;
    for (var cmd in possibleCMDs) {
      try {
        var process = Process.runSync(cmd, args);
        if (process.exitCode == exitCode) {
          return process.stdout;
        }
      } catch (e) {
        error == e;
        continue;
      }
    }

    if (error != null) {
      throw error;
    } else {
      throw StateError("Can't run any of the possible commands: $possibleCMDs");
    }
  }

  @override
  String toString() =>
      'RandomX{ id: $id, fullMemory: $fullMemory, sizeOfHash: $sizeOfHash, initKey: ${initKey?.toHex()}, platform: $platform }';
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
