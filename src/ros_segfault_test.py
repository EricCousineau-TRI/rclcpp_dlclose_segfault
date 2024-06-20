import argparse
import itertools
import subprocess
import time


def run_check(argv, num_parallel, count):
    queue = []
    num_fail = 0
    keep_result = True
    num_run = 0
    returncodes = set()
    error_texts = set()

    def poll():
        nonlocal num_fail, keep_result, returncodes, error_texts
        for proc in list(queue):
            if proc.poll() is not None:
                proc.wait()
                queue.remove(proc)
                returncodes.add(proc.returncode)
                if keep_result and proc.returncode != 0:
                    num_fail += 1
                    text = proc.stdout.read().strip()
                    error_texts.add(text)
        time.sleep(0.01)

    if count == 0:
        print("Running forever. Press Ctrl+C to stop.")
        my_range = itertools.count()
    else:
        my_range = range(count)

    try:
        for i in my_range:
            # Wait for queue to free up.
            while len(queue) >= num_parallel:
                poll()
            # Add proc.
            proc = subprocess.Popen(
                argv,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
            )
            queue.append(proc)
            num_run += 1
        while len(queue) > 0:
            poll()
    except KeyboardInterrupt:
        keep_result = False
        print()
    finally:
        num_run -= len(queue)

    print(f"num_fail: {num_fail} / {num_run}")
    error_text_join = "\n".join(error_texts)
    print(f"returncodes: {returncodes}")
    print(error_text_join)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--modes", type=str, nargs="+", default=None)
    parser.add_argument("--count", type=int, default=200)
    parser.add_argument("--num_parallel", type=int, default=50)
    args = parser.parse_args()

    direct_bin = "./build/ros_segfault_min_direct"
    dlopen_bin = "./build/ros_segfault_min_dlopen"
    solib_bin = "./build/libros_segfault_min_lib.so"

    argv_map = {
        "direct_leak": [
            direct_bin,
            "InitAndLeakNode",
        ],
        "dlopen_noleak": [
            dlopen_bin,
            solib_bin,
            "InitNode",
        ],
        "dlopen_leak": [
            dlopen_bin,
            solib_bin,
            "InitAndLeakNode",
        ],
    }

    if args.modes is not None:
        argv_map = {mode: argv_map[mode] for mode in args.modes}

    for name, argv in argv_map.items():
        print(f"[ {name} ]")
        run_check(argv, args.num_parallel, args.count)


if __name__ == "__main__":
    main()
