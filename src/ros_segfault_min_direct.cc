#undef NDEBUG
#include <dlfcn.h>
#include <cassert>
#include <cstring>

#include "ros_segfault_min_lib.h"

int main(int argc, char** argv) {
  assert(argc == 2);
  if (strcmp(argv[1], "InitNode") == 0) {
    InitNode();
  } else if (strcmp(argv[1], "InitAndLeakNode") == 0) {
    InitAndLeakNode();
  } else {
    assert(false);
  }
  return 0;
}
