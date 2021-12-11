#!/bin/bash

set -x

make clean
cmake .
make

if [ -f "libwrapper_randomx.1.0.0.dylib" ]; then
	rm libwrapper_randomx.dylib
    cp -f libwrapper_randomx.1.0.0.dylib libwrapper_randomx.dylib
fi

if [ -f "libwrapper_randomx.so.1.0.0" ]; then
	rm libwrapper_randomx.so
    cp -f libwrapper_randomx.so.1.0.0 libwrapper_randomx.so
fi
