#!/bin/bash

set -x

cd wrapper_randomx_library

rm -rf ./RandomX

cd ..

dart pub publish
