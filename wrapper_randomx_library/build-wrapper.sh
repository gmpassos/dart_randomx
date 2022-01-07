#!/bin/bash

set -x

cp -f CMakeLists-linux-macos.txt CMakeLists.txt

make clean
cmake .
make

if [ -f "libwrapper_randomx.1.0.0.dylib" ]; then

	if [[ `uname -m` == 'arm64' ]]; then
	  rm libwrapper_randomx.dylib
    rm libwrapper_randomx-arm64.dylib

    cp -f libwrapper_randomx.1.0.0.dylib libwrapper_randomx-arm64.dylib
    cp -f libwrapper_randomx-x64.dylib libwrapper_randomx.dylib
  else
    rm libwrapper_randomx.dylib
    rm libwrapper_randomx-x64.dylib

    cp -f libwrapper_randomx.1.0.0.dylib libwrapper_randomx-x64.dylib
    cp -f libwrapper_randomx.1.0.0.dylib libwrapper_randomx.dylib
  fi

fi

if [ -f "libwrapper_randomx.so.1.0.0" ]; then
	rm libwrapper_randomx.so
  cp -f libwrapper_randomx.so.1.0.0 libwrapper_randomx.so
fi
