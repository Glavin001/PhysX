// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "native_convergence_check.h"
int main(){try{nativeConvergenceTest::run();return 0;}
    catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
