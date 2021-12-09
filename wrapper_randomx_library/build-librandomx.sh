#!/bin/bash

set -x

git -C RandomX pull || git clone https://github.com/tevador/RandomX.git

cd RandomX

mkdir -p build
cd build

make clean
cmake ..
make

cd ..

ls -al build/lib*

cp -f build/lib* ..
