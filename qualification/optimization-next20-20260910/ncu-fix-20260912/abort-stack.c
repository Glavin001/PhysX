#define _GNU_SOURCE
#include <execinfo.h>
#include <signal.h>
#include <unistd.h>
static void failed(int signal) {
    void *frames[80];
    write(2,"\nNCU_DIAGNOSTIC_ABORT_STACK\n",28);
    int n=backtrace(frames,80);
    backtrace_symbols_fd(frames,n,2);
    _exit(128+signal);
}
__attribute__((constructor)) static void init(void) {
    void *frames[2];backtrace(frames,2);
    struct sigaction action={0};action.sa_handler=failed;sigemptyset(&action.sa_mask);
    sigaction(SIGABRT,&action,0);
}
