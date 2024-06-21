#!/bin/bash
set -eu

rm -rf build
cmake -S . -B build -DCMAKE_C_FLAGS=-fsanitize=undefined -DCMAKE_CXX_FLAGS=-fsanitize=undefined
cmake --build build -j

set -x
set +e

export UBSAN_OPTIONS="print_stacktrace=1"

# No issues reported anywhere?

(
./build/ros_segfault_min_direct InitNode

./build/ros_segfault_min_direct InitAndLeakNode

./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitNode

./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitAndLeakNode

) 2>&1 | tee ./run_ubsan.output.txt
