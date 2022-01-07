#!/bin/bash

set -x

git -C RandomX pull || git clone https://github.com/tevador/RandomX.git

cp -f configuration-monero.h ./RandomX/src/configuration.h

cd RandomX

mkdir -p build
cd build

ninja clean
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS="-m64" -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-m64" ..
ninja

cd ..

ls -al build/lib*

cp -f build/lib* ..
