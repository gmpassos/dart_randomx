#!/bin/bash

set -x

make clean
cmake .
make

cp -f libwrapper_randomx.1.0.0.dylib libwrapper_randomx.so
