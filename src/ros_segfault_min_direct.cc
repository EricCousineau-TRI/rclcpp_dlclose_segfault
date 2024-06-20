#undef NDEBUG
#include <dlfcn.h>
#include <cassert>

#include "ros_segfault_min_lib.h"

int main(int argc, char** argv) {

  InitAndLeakNode();
  return 0;
}
