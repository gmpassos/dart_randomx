#!/bin/bash

set -x

make clean
cmake .
make
