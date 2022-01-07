#!/bin/bash

set -x

ninja clean

cd RandomX
ninja clean

cd ..

rm librandomx*
