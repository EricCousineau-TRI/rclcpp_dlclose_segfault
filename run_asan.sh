#!/bin/bash
set -eu

rm -rf build
cmake -S . -B build -DCMAKE_C_FLAGS=-fsanitize=address -DCMAKE_CXX_FLAGS=-fsanitize=address
cmake --build build -j

export ASAN_OPTIONS=new_delete_type_mismatch=0

set -x
set +e

(
# No issues.
./build/ros_segfault_min_direct InitNode
echo

# Some issues, expected.
./build/ros_segfault_min_direct InitAndLeakNode
echo

# Some issues, not expected?
./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitNode
echo

# Err.. Asan itself segfaults?
./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitAndLeakNode
# Runnign with `gdb ---args` prefix, I see:
# ==777154==LeakSanitizer has encountered a fatal error.
# ==777154==HINT: For debugging, try setting environment variable LSAN_OPTIONS=verbosity=1:log_threads=1
# ==777154==HINT: LeakSanitizer does not work under ptrace (strace, gdb, etc)
) 2>&1 | tee ./run_asan.output.txt
