#!/bin/bash

set -x

cp -f CMakeLists-mingw64.txt CMakeLists.txt

ninja clean
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS="-m64" .
ninja

