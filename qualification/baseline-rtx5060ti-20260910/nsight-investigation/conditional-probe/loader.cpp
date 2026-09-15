#include <dlfcn.h>
#include <cstdio>
int main(int argc,char**argv){void*lib=dlopen(argv[1],RTLD_NOW|RTLD_LOCAL);if(!lib){puts(dlerror());return 2;}auto run=(int(*)())dlsym(lib,"run");return run?run():3;}
