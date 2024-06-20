#undef NDEBUG
#include <dlfcn.h>
#include <cassert>

typedef void (*VoidFunc)();

int main(int argc, char** argv) {
  // {me} {lib} {sym}
  assert(argc == 3);
  const char* solib_file = argv[1];
  const char* sym = argv[2];

  void* solib = dlopen(solib_file, RTLD_LAZY);
  assert(solib != nullptr);
  auto* func = reinterpret_cast<VoidFunc>(dlsym(solib, sym));
  assert(func != nullptr);

  func();

  dlclose(solib);
  return 0;
}
