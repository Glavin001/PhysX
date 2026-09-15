#pragma once
#include <cstdio>
#include <cstdlib>
#include <stdexcept>

// Physical assertions remain mandatory. This opt-in additionally pins the
// current scheduling/arithmetic implementation for targeted investigations.
inline void implementationDiagnostic(bool same, const char* message) {
    if (same) return;
    std::fprintf(stderr, "implementation diagnostic: %s\n", message);
    const char* strict = std::getenv("PHYSX_DESTRUCTION_STRICT_DIAGNOSTICS");
    if (strict && strict[0] == '1') throw std::runtime_error(message);
}
