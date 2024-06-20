# `rclcpp_dlclose_segfault`

## Output

Errors w/ `dlopen_leak` are non-deterministic

```sh
# Non-standard build, but just want to focus on issue.
$ source /opt/ros/humble/setup.bash
$ cmake -S . -B build
$ cmake --build build -j

$ python ./src/ros_segfault_test.py
[ direct_leak ]
num_fail: 0 / 200
returncodes: {0}

[ dlopen_noleak ]
num_fail: 0 / 200
returncodes: {0}

[ dlopen_leak ]
num_fail: 185 / 200
returncodes: {0, -11, 127}

./build/ros_segfault_min_dlopen: symbol lookup error: /opt/ros/humble/lib/x86_64-linux-gnu/libddsc.so.0: undefined symbol: ddsrt_avl_swap_node
./build/ros_segfault_min_dlopen: symbol lookup error: /opt/ros/humble/lib/x86_64-linux-gnu/libddsc.so.0: undefined symbol: ddsrt_ehh_new
./build/ros_segfault_min_dlopen: symbol lookup error: /opt/ros/humble/lib/x86_64-linux-gnu/libddsc.so.0: undefined symbol: ddsi_update_proxy_writer
./build/ros_segfault_min_dlopen: symbol lookup error: /opt/ros/humble/lib/x86_64-linux-gnu/libddsc.so.0: undefined symbol: ddsi_update_proxy_reader
./build/ros_segfault_min_dlopen: symbol lookup error: /opt/ros/humble/lib/x86_64-linux-gnu/libddsc.so.0: undefined symbol: plist_fini_generic
./build/ros_segfault_min_dlopen: symbol lookup error: /opt/ros/humble/lib/x86_64-linux-gnu/libddsc.so.0: undefined symbol: ddsrt_avl_free_arg
```

## Attaching GDB

```sh
# Terminal 1: Run background stuff to incite segfault.
$ python ./src/ros_segfault_test.py --modes dlopen_leak --count 0

# Terminal 2: Run with gdb.
$ gdb --args ./build/ros_segfault_min_dlopen ./build/libros_segfault_min_lib.so InitAndLeakNode
# show backtrace on all threads
(gdb) thread apply all bt
```

Example stacktrace from main thread:
```
Thread 1 (Thread 0x7ffff7f8c740 (LWP 207729) "ros_segfault_mi"):
#0  __GI__dl_debug_state () at ./elf/dl-debug.c:117
#1  0x00007ffff7fc5c24 in _dl_close_worker (force=force@entry=false, map=<optimized out>, map=<optimized out>) at ./elf/dl-close.c:769
#2  0x00007ffff7fc62a2 in _dl_close_worker (force=false, map=0x555555579330) at ./elf/dl-close.c:150
#3  _dl_close (_map=0x555555579330) at ./elf/dl-close.c:818
#4  0x00007ffff7d74a98 in __GI__dl_catch_exception (exception=exception@entry=0x7fffffffd090, operate=<optimized out>, args=<optimized out>) at ./elf/dl-error-skeleton.c:208
#5  0x00007ffff7d74b63 in __GI__dl_catch_error (objname=0x7fffffffd0e8, errstring=0x7fffffffd0f0, mallocedp=0x7fffffffd0e7, operate=<optimized out>, args=<optimized out>) at ./elf/dl-error-skeleton.c:227
#6  0x00007ffff7c9012e in _dlerror_run (operate=<optimized out>, args=<optimized out>) at ./dlfcn/dlerror.c:138
#7  0x00007ffff7c8fe58 in __dlclose (handle=<optimized out>) at ./dlfcn/dlclose.c:31
#8  0x00007ffff7fa021d in rcutils_unload_shared_library () from /opt/ros/humble/lib/librcutils.so
#9  0x00007ffff7ea9370 in rcpputils::SharedLibrary::~SharedLibrary() () from /opt/ros/humble/lib/librcpputils.so
#10 0x00007ffff7ed0a66 in ?? () from /opt/ros/humble/lib/librmw_implementation.so
#11 0x00007ffff7c45495 in __run_exit_handlers (status=0, listp=0x7ffff7e1a838 <__exit_funcs>, run_list_atexit=run_list_atexit@entry=true, run_dtors=run_dtors@entry=true) at ./stdlib/exit.c:113
#12 0x00007ffff7c45610 in __GI_exit (status=<optimized out>) at ./stdlib/exit.c:143
#13 0x00007ffff7c29d97 in __libc_start_call_main (main=main@entry=0x5555555551a9 <main>, argc=argc@entry=3, argv=argv@entry=0x7fffffffd748) --Type <RET> for more, q to quit, c to continue without paging--
at ../sysdeps/nptl/libc_start_call_main.h:74
#14 0x00007ffff7c29e40 in __libc_start_main_impl (main=0x5555555551a9 <main>, argc=3, argv=0x7fffffffd748, init=<optimized out>, fini=<optimized out>, rtld_fini=<optimized out>, stack_end=0x7fffffffd738) at ../csu/libc-start.c:392
#15 0x00005555555550e5 in _start ()
```
