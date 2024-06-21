#!/bin/bash
set -eu

rm -rf build
cmake -S . -B build
cmake --build build -j

set -x
set +e

# No errors if we don't pass --leak-check=full
tool="valgrind --leak-check=full"

(

# One issue.
${tool} ./build/ros_segfault_min_direct InitNode
echo

# Some issues, expected.
${tool} ./build/ros_segfault_min_direct InitAndLeakNode
echo

# Some issues, not expected?
${tool} ./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitNode
echo

${tool} ./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitAndLeakNode

) 2>&1 | tee ./run_valgrind.output.txt
