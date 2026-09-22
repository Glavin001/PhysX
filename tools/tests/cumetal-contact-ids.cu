// Qualify the fork's shared lifetime allocation tests, not substitute equations.
#include "../../physx/source/gpudestruction/tests/contact_identity_test.cuh"
int main() {
    try { contactLifetimeAllocation(); return 0; }
    catch(const std::exception& e) { std::fprintf(stderr,"%s\n",e.what()); return 1; }
}
